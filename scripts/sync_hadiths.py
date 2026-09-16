import os
import re
import json
import glob

def parse_markdown_to_json():
    base_dir = r"c:\Users\USER\flutter_projects\Alfu Hadithin Wa Hadith"
    book_dir = os.path.join(base_dir, "book")
    output_file = os.path.join(base_dir, "data", "hadiths.json")
    chapters_file = os.path.join(base_dir, "data", "chapters.json")
    
    md_files = sorted(glob.glob(os.path.join(book_dir, "*.md")))
    all_hadiths = []
    chapters_list = []
    
    for file_idx, md_file in enumerate(md_files):
        with open(md_file, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Extract Chapter titles from header lines (# Chapter ...)
        header_lines = [line.strip() for line in content.split("\n") if line.strip().startswith("# ")]
        chapter_en = ""
        chapter_ar = ""
        if len(header_lines) >= 1:
            chapter_en = header_lines[0].lstrip("# ").strip()
        if len(header_lines) >= 2:
            chapter_ar = header_lines[1].lstrip("# ").strip()
            
        chapter_num_match = re.search(r"(\d+)", os.path.basename(md_file))
        chapter_id = int(chapter_num_match.group(1)) if chapter_num_match else file_idx
        
        # Split into hadith entries by "### Hadith #"
        hadith_splits = re.split(r"(?:^|\n)###\s+Hadith\s+#(\d+)", content)
        
        hadith_count_in_chapter = 0
        if len(hadith_splits) > 1:
            for i in range(1, len(hadith_splits), 2):
                h_id = int(hadith_splits[i])
                block = hadith_splits[i+1].strip()
                hadith_count_in_chapter += 1
                
                # Extract Sub-topic / Topic
                topic_match = re.search(r"\*\*\[Topic\s*/\s*Chapter:\s*(.+?)\]\*\*", block)
                topic_raw = topic_match.group(1).strip() if topic_match else ""
                
                subtopic_match = re.search(r"\*Sub-topic:\s*(.+?)\*", block)
                subtopic_raw = subtopic_match.group(1).strip() if subtopic_match else ""
                
                # Extract Arabic Matn
                matn_match = re.search(r"\*\*\[Arabic Matn with Tashkeel\]:\*\*\s*\n+(.+?)(?=\n+\*\*\[Narrator\]:)", block, re.DOTALL)
                arabic_matn = matn_match.group(1).strip() if matn_match else ""
                
                # Extract Narrator
                narrator_match = re.search(r"\*\*\[Narrator\]:\*\*\s*(.+?)(?=\s*\n+\*\*\[English Translation\]:)", block, re.DOTALL)
                narrator = narrator_match.group(1).strip() if narrator_match else ""
                
                # Extract English Translation
                trans_match = re.search(r"\*\*\[English Translation\]:\*\*\s*(.+?)(?=\s*\n+\*\*\[Reference & Grading\]:)", block, re.DOTALL)
                translation = trans_match.group(1).strip() if trans_match else ""
                
                # Extract Reference & Grading
                ref_match = re.search(r"\*\*\[Reference & Grading\]:\*\*\s*(.+?)(?=\s*\n+\*\*\[Key Benefit / Takeaway\]:|\Z)", block, re.DOTALL)
                ref_and_grading = ref_match.group(1).strip() if ref_match else ""
                
                # Extract Benefit / Takeaway
                benefit_match = re.search(r"\*\*\[Key Benefit / Takeaway\]:\*\*\s*(.+?)(?=\n+---|\Z)", block, re.DOTALL)
                benefit = benefit_match.group(1).strip() if benefit_match else ""
                
                all_hadiths.append({
                    "id": h_id,
                    "id_str": f"#{h_id:04d}",
                    "chapter_id": chapter_id,
                    "chapter_title_en": chapter_en,
                    "chapter_title_ar": chapter_ar,
                    "topic": topic_raw,
                    "subtopic": subtopic_raw,
                    "arabic_matn": arabic_matn,
                    "narrator": narrator,
                    "english_translation": translation,
                    "reference_and_grading": ref_and_grading,
                    "key_benefit": benefit,
                    "source": "المكتبة الشاملة (shamela.ws)"
                })
                
        chapters_list.append({
            "chapter_id": chapter_id,
            "filename": os.path.basename(md_file),
            "title_en": chapter_en,
            "title_ar": chapter_ar,
            "hadith_count": hadith_count_in_chapter
        })

    all_hadiths.sort(key=lambda x: x["id"])
    
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(all_hadiths, f, ensure_ascii=False, indent=2)
        
    with open(chapters_file, "w", encoding="utf-8") as f:
        json.dump(chapters_list, f, ensure_ascii=False, indent=2)
        
    print(f"Successfully processed {len(all_hadiths)} hadiths across {len(chapters_list)} chapters into {output_file}")
    
    # Validation checks
    ids = [h["id"] for h in all_hadiths]
    if len(ids) == 1001 and min(ids) == 1 and max(ids) == 1001:
        print("PERFECT: Exactly 1001 Hadiths found with continuous IDs from 1 to 1001!")
    else:
        print(f"Total Hadiths found: {len(ids)}, Min: {min(ids) if ids else None}, Max: {max(ids) if ids else None}")
        missing = set(range(1, 1002)) - set(ids)
        if missing:
            print(f"Missing IDs: {sorted(list(missing))[:20]}")

if __name__ == "__main__":
    parse_markdown_to_json()
