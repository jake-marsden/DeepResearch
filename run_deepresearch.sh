#!/bin/bash
# Orchestrate DeepResearch inference and markdown conversion

set -e  # Exit on error

# Default values
DATASET=""
OUTPUT_DIR="./outputs"
MODEL="amazon.nova-pro-v1:0"
MAX_WORKERS=2
TEMPERATURE=0.7
ROLLOUT_COUNT=1
MARKDOWN_OUTPUT=""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse arguments
show_help() {
    cat << EOF
Usage: bash run_deepresearch.sh [OPTIONS]

Orchestrate DeepResearch inference and markdown conversion

OPTIONS:
    -d, --dataset FILE          Input JSONL dataset (required)
    -o, --output DIR            Output directory (default: ./outputs)
    -m, --model MODEL           Model ID (default: amazon.nova-pro-v1:0)
    -w, --workers NUM           Max workers (default: 2)
    -t, --temperature NUM       Temperature (default: 0.7)
    -r, --rollouts NUM          Rollout count (default: 1)
    --markdown FILE             Custom markdown output path (optional)
    -h, --help                  Show this help message

EXAMPLES:
    # Basic usage
    bash run_deepresearch.sh -d my_questions.jsonl

    # With custom output
    bash run_deepresearch.sh -d my_questions.jsonl -o results --markdown my_answers.md

    # With different model
    bash run_deepresearch.sh -d my_questions.jsonl -m amazon.nova-lite-v1:0

AVAILABLE MODELS:
    - amazon.nova-pro-v1:0      (default, good balance)
    - amazon.nova-lite-v1:0     (fastest)
    - anthropic.claude-sonnet-4-5-20250929-v1:0 (highest quality)

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dataset)
            DATASET="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -w|--workers)
            MAX_WORKERS="$2"
            shift 2
            ;;
        -t|--temperature)
            TEMPERATURE="$2"
            shift 2
            ;;
        -r|--rollouts)
            ROLLOUT_COUNT="$2"
            shift 2
            ;;
        --markdown)
            MARKDOWN_OUTPUT="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$DATASET" ]; then
    echo -e "${RED}❌ Error: Dataset is required${NC}"
    echo ""
    show_help
    exit 1
fi

if [ ! -f "$DATASET" ]; then
    echo -e "${RED}❌ Error: Dataset file not found: $DATASET${NC}"
    exit 1
fi

# Get absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ ! "$DATASET" = /* ]]; then
    DATASET="$SCRIPT_DIR/$DATASET"
fi

if [[ ! "$OUTPUT_DIR" = /* ]]; then
    OUTPUT_DIR="$SCRIPT_DIR/$OUTPUT_DIR"
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🚀 DeepResearch Orchestrator${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}📋 Configuration:${NC}"
echo "   Dataset:     $DATASET"
echo "   Output Dir:  $OUTPUT_DIR"
echo "   Model:       $MODEL"
echo "   Workers:     $MAX_WORKERS"
echo "   Temperature: $TEMPERATURE"
echo "   Rollouts:    $ROLLOUT_COUNT"
echo ""

# Step 1: Check Bedrock proxy
echo -e "${YELLOW}🔍 Step 1/3: Checking Bedrock Proxy...${NC}"
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Bedrock proxy is running${NC}"
else
    echo -e "${RED}   ❌ Bedrock proxy not running${NC}"
    echo -e "${YELLOW}   🚀 Starting Bedrock proxy...${NC}"
    export AWS_PROFILE=baizantium
    export AWS_REGION=ap-southeast-2
    nohup python3 bedrock_proxy.py > bedrock_proxy.log 2>&1 &
    sleep 3
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Bedrock proxy started${NC}"
    else
        echo -e "${RED}   ❌ Failed to start Bedrock proxy${NC}"
        exit 1
    fi
fi
echo ""

# Step 2: Run DeepResearch inference
echo -e "${YELLOW}🧠 Step 2/3: Running DeepResearch Inference...${NC}"
echo ""

cd inference

python3 -u run_multi_react.py \
    --dataset "$DATASET" \
    --output "$OUTPUT_DIR" \
    --max_workers "$MAX_WORKERS" \
    --model "$MODEL" \
    --temperature "$TEMPERATURE" \
    --roll_out_count "$ROLLOUT_COUNT"

INFERENCE_EXIT_CODE=$?

cd "$SCRIPT_DIR"

if [ $INFERENCE_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}❌ Inference failed with exit code $INFERENCE_EXIT_CODE${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Inference completed successfully!${NC}"
echo ""

# Step 3: Find the output JSONL and convert to markdown
echo -e "${YELLOW}📝 Step 3/3: Converting to Markdown...${NC}"

# Find the most recent iter1.jsonl file
DATASET_NAME=$(basename "$DATASET" .jsonl)
RESULT_JSONL=$(find "$OUTPUT_DIR" -name "iter1.jsonl" -path "*$DATASET_NAME*" -type f -mmin -10 | head -1)

if [ -z "$RESULT_JSONL" ]; then
    # Fallback: find any recent iter1.jsonl
    RESULT_JSONL=$(find "$OUTPUT_DIR" -name "iter1.jsonl" -type f -mmin -10 | head -1)
fi

if [ -z "$RESULT_JSONL" ]; then
    echo -e "${RED}❌ Error: Could not find result file${NC}"
    echo "   Searched in: $OUTPUT_DIR"
    exit 1
fi

echo "   Found results: $RESULT_JSONL"

# Determine markdown output path
if [ -z "$MARKDOWN_OUTPUT" ]; then
    MARKDOWN_OUTPUT="$SCRIPT_DIR/${DATASET_NAME}_answers.md"
fi

# Convert to markdown
python3 extract_answers.py "$RESULT_JSONL" "$MARKDOWN_OUTPUT"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 ALL DONE!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}📁 Your Results:${NC}"
echo "   JSON:     $RESULT_JSONL"
echo "   Markdown: $MARKDOWN_OUTPUT"
echo ""
echo -e "${BLUE}View answers:${NC}"
echo "   cat $MARKDOWN_OUTPUT"
echo ""

