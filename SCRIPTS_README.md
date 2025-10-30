# 📚 DeepResearch Scripts Guide

## 🎯 Two Main Scripts

### 1. **extract_answers.py** - Convert JSON to Markdown
Extracts answers from DeepResearch JSON output and creates a readable markdown file.

**Usage:**
```bash
python3 extract_answers.py <input_jsonl> [output_md]
```

**Examples:**
```bash
# Auto-generate output filename
python3 extract_answers.py outputs/my_questions.jsonl/iter1.jsonl

# Custom output filename
python3 extract_answers.py outputs/my_questions.jsonl/iter1.jsonl my_results.md
```

**What it does:**
- Reads all answers from the JSONL file
- Creates a nicely formatted markdown file
- Includes metadata (timestamps, success rate)
- Numbers all questions
- Shows termination status

---

### 2. **run_deepresearch.sh** - Full Orchestration
Runs the entire pipeline: inference → markdown conversion

**Usage:**
```bash
bash run_deepresearch.sh -d <dataset> [OPTIONS]
```

**Options:**
```
-d, --dataset FILE       Input JSONL dataset (required)
-o, --output DIR         Output directory (default: ./outputs)
-m, --model MODEL        Model ID (default: amazon.nova-pro-v1:0)
-w, --workers NUM        Max workers (default: 2)
-t, --temperature NUM    Temperature (default: 0.7)
-r, --rollouts NUM       Rollout count (default: 1)
--markdown FILE          Custom markdown output (optional)
-h, --help               Show help
```

**Examples:**
```bash
# Simple - just provide your questions
bash run_deepresearch.sh -d my_questions.jsonl

# Custom everything
bash run_deepresearch.sh \
  -d my_questions.jsonl \
  -o custom_outputs \
  -m amazon.nova-lite-v1:0 \
  -w 4 \
  --markdown final_answers.md

# Fast model for quick testing
bash run_deepresearch.sh -d test.jsonl -m amazon.nova-lite-v1:0
```

**What it does:**
1. ✅ Checks if Bedrock proxy is running (starts it if needed)
2. ✅ Runs DeepResearch inference
3. ✅ Automatically finds the output JSON
4. ✅ Converts to markdown
5. ✅ Shows you where to find results

---

## 📋 Complete Workflow

### Step 1: Create Your Questions
```bash
cat > my_questions.jsonl << EOF
{"question": "What is quantum computing?", "answer": ""}
{"question": "How does CRISPR work?", "answer": ""}
{"question": "What caused the 2008 financial crisis?", "answer": ""}
EOF
```

### Step 2: Run Complete Pipeline
```bash
bash run_deepresearch.sh -d my_questions.jsonl
```

### Step 3: View Results
```bash
cat my_questions_answers.md
```

**That's it!** Three simple steps to get comprehensive AI research on any topic.

---

## 🔧 Advanced Usage

### Run with Different Models

**Fastest (Nova Lite):**
```bash
bash run_deepresearch.sh -d questions.jsonl -m amazon.nova-lite-v1:0
```

**Best Quality (Claude Sonnet 4.5):**
```bash
bash run_deepresearch.sh -d questions.jsonl -m anthropic.claude-sonnet-4-5-20250929-v1:0
```

**Balance (Nova Pro - Default):**
```bash
bash run_deepresearch.sh -d questions.jsonl -m amazon.nova-pro-v1:0
```

### Parallel Processing

Process multiple questions simultaneously:
```bash
bash run_deepresearch.sh -d large_dataset.jsonl -w 10
```

This will process up to 10 questions in parallel (faster for large datasets).

### Custom Output Location

```bash
bash run_deepresearch.sh \
  -d my_questions.jsonl \
  -o /path/to/results \
  --markdown /path/to/answers.md
```

---

## 📊 Output Files

After running, you'll get:

**1. JSON Output (complete data):**
```
outputs/
└── my_questions.jsonl/
    └── iter1.jsonl          # Full results with conversation history
```

**2. Markdown Output (readable):**
```
my_questions_answers.md      # Nicely formatted answers
```

**3. Logs:**
```
bedrock_proxy.log            # Bedrock API calls
```
