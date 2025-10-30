#!/usr/bin/env python3
"""
Extract answers from DeepResearch JSON output and convert to markdown
"""
import json
import sys
import os
from datetime import datetime
from pathlib import Path

def extract_answers_to_markdown(input_jsonl, output_md):
    """
    Extract answers from DeepResearch JSONL output and create a markdown file
    
    Args:
        input_jsonl: Path to the iter1.jsonl file with results
        output_md: Path to the output markdown file
    """
    
    # Read all results
    results = []
    with open(input_jsonl, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line:  # Skip empty lines
                results.append(json.loads(line))
    
    # Create markdown content
    md_content = []
    md_content.append("# 🎯 DeepResearch Results\n")
    md_content.append(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    md_content.append(f"**Total Questions:** {len(results)}\n")
    md_content.append(f"**Source:** `{input_jsonl}`\n")
    md_content.append("\n---\n")
    
    # Add each Q&A
    for i, result in enumerate(results, 1):
        question = result.get('question', 'N/A')
        prediction = result.get('prediction', 'No answer generated')
        termination = result.get('termination', 'unknown')
        
        md_content.append(f"\n## Question {i}\n")
        md_content.append(f"**Q:** {question}\n")
        md_content.append(f"\n**Answer:**\n\n{prediction}\n")
        md_content.append(f"\n*Status: {termination}*\n")
        md_content.append("\n---\n")
    
    # Add metadata footer
    md_content.append("\n## 📊 Metadata\n")
    md_content.append(f"- **Total Questions:** {len(results)}\n")
    md_content.append(f"- **Successful:** {sum(1 for r in results if 'error' not in r or not r.get('error'))}\n")
    md_content.append(f"- **Failed:** {sum(1 for r in results if r.get('error'))}\n")
    
    # Write markdown file
    with open(output_md, 'w', encoding='utf-8') as f:
        f.write(''.join(md_content))
    
    print(f"✅ Markdown file created: {output_md}")
    print(f"📊 Processed {len(results)} questions")
    
    return output_md

def main():
    if len(sys.argv) < 2:
        print("Usage: python extract_answers.py <input_jsonl> [output_md]")
        print("\nExample:")
        print("  python extract_answers.py outputs/my_questions.jsonl/iter1.jsonl")
        print("  python extract_answers.py outputs/my_questions.jsonl/iter1.jsonl my_results.md")
        sys.exit(1)
    
    input_jsonl = sys.argv[1]
    
    # Auto-generate output filename if not provided
    if len(sys.argv) >= 3:
        output_md = sys.argv[2]
    else:
        # Create output filename based on input
        input_path = Path(input_jsonl)
        output_md = str(input_path.parent / f"{input_path.stem}_results.md")
    
    # Check if input exists
    if not os.path.exists(input_jsonl):
        print(f"❌ Error: Input file not found: {input_jsonl}")
        sys.exit(1)
    
    # Extract and convert
    try:
        output_file = extract_answers_to_markdown(input_jsonl, output_md)
        print(f"\n🎉 Success! View your answers at:")
        print(f"   {output_file}")
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()

