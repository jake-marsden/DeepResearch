# 🚀 DeepResearch - Complete Usage Guide

## ✅ Your Setup Summary

**Your Configuration:**
- **API_BASE:** `http://localhost:8000/v1` (AWS Bedrock proxy)
- **SUMMARY_MODEL_NAME:** `anthropic.claude-3-5-sonnet-20241022-v2:0`
- **Main Model:** Amazon Nova Pro (`amazon.nova-pro-v1:0`)
- **Speed:** ~5 seconds per question
- **Cost:** FREE (AWS Bedrock credits)

---

## 🎯 Two Ways to Use DeepResearch

### **Method 1: Full Automation** (Recommended)

One command does everything - inference + markdown conversion:

```bash
bash run_deepresearch.sh -d my_questions.jsonl
```

**Output:**
- JSON results in `outputs/`
- Markdown file: `my_questions_answers.md`

### **Method 2: Manual Steps**

Run inference and conversion separately:

```bash
# Step 1: Run inference
cd inference
python3 run_multi_react.py \
  --dataset ../my_questions.jsonl \
  --output ../outputs \
  --model amazon.nova-pro-v1:0

# Step 2: Convert to markdown
cd ..
python3 extract_answers.py outputs/my_questions.jsonl/iter1.jsonl
```

---

## 📝 Creating Question Files

### Format: JSONL (one JSON object per line)

**Single Question:**
```bash
echo '{"question": "What is quantum computing?", "answer": ""}' > question.jsonl
```

**Multiple Questions:**
```bash
cat > my_research.jsonl << EOF
{"question": "What is quantum computing?", "answer": ""}
{"question": "How does CRISPR gene editing work?", "answer": ""}
{"question": "What are the benefits of renewable energy?", "answer": ""}
EOF
```

**Your Current File (`my_questions.jsonl`):**
```jsonl
{"question": "Who is the best NBA player of all time?", "answer": ""}
{"question": "Who has been the wealthiest individual for the longest period of time since 2000?", "answer": ""}
```

---

## 🚀 Quick Examples

### Example 1: Your Current Questions
```bash
bash run_deepresearch.sh -d my_questions.jsonl
cat my_questions_answers.md
```

### Example 2: Single Quick Question
```bash
echo '{"question": "Who invented the internet?", "answer": ""}' > quick.jsonl
bash run_deepresearch.sh -d quick.jsonl
cat quick_answers.md
```

### Example 3: Multiple Topics with Fast Model
```bash
cat > research.jsonl << EOF
{"question": "What is climate change?", "answer": ""}
{"question": "How do vaccines work?", "answer": ""}
{"question": "What is machine learning?", "answer": ""}
EOF

bash run_deepresearch.sh -d research.jsonl -m amazon.nova-lite-v1:0 -w 3
cat research_answers.md
```

### Example 4: High-Quality Research
```bash
bash run_deepresearch.sh \
  -d important_questions.jsonl \
  -m anthropic.claude-sonnet-4-5-20250929-v1:0 \
  --markdown final_report.md
```

---

## 📊 Model Selection Guide

| Model | Speed | Quality | Cost | Use When |
|-------|-------|---------|------|----------|
| **nova-lite** | ⚡⚡⚡⚡⚡ | ⭐⭐⭐ | $ | Quick testing, simple questions |
| **nova-pro** ⭐ | ⚡⚡⚡⚡ | ⭐⭐⭐⭐ | $$ | **Default - Best balance** |
| **claude-4.5** | ⚡⚡⚡ | ⭐⭐⭐⭐⭐ | $$$ | Complex research, best quality |

To use a different model:
```bash
bash run_deepresearch.sh -d questions.jsonl -m MODEL_ID
```

---

## 🔍 Finding Your Results

### After running `run_deepresearch.sh`:

**Markdown (Easy to Read):**
```bash
cat DATASET_NAME_answers.md
```

**JSON (Complete Data):**
```bash
cat outputs/MODEL_NAME_sglang/DATASET_NAME/iter1.jsonl | python3 -m json.tool
```

### Your Current Results:

```bash
# NBA + Wealth questions (already done)
cat outputs/my_questions.jsonl/iter1_results.md

# Or the auto-generated one
ls -lh *_answers.md
```

---

## 🛠️ Advanced Options

### Parallel Processing (Faster for Many Questions)

```bash
# Process 5 questions simultaneously
bash run_deepresearch.sh -d large_dataset.jsonl -w 5
```

### Custom Output Location

```bash
bash run_deepresearch.sh \
  -d questions.jsonl \
  -o /path/to/results \
  --markdown /path/to/final_report.md
```

### Temperature Control

```bash
# More creative (higher temperature)
bash run_deepresearch.sh -d questions.jsonl -t 0.9

# More focused (lower temperature)
bash run_deepresearch.sh -d questions.jsonl -t 0.3
```

### Multiple Rollouts (for consistency checking)

```bash
# Run 3 times to compare answers
bash run_deepresearch.sh -d questions.jsonl -r 3
```
