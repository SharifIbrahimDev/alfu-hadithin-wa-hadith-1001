using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;

public class HadithDataExporter
{
    public class HadithItem
    {
        public int id { get; set; }
        public string id_str { get; set; }
        public int chapter_id { get; set; }
        public string chapter_title_ar { get; set; }
        public string chapter_title_en { get; set; }
        public string topic_ar { get; set; }
        public string topic_en { get; set; }
        public string arabic_matn { get; set; }
        public string narrator_ar { get; set; }
        public string narrator_en { get; set; }
        public string english_translation { get; set; }
        public string takhrij { get; set; }
        public string grading { get; set; }
        public string benefits_ar { get; set; }
        public string benefits_en { get; set; }
    }

    public class ChapterItem
    {
        public int id { get; set; }
        public string filename { get; set; }
        public string title_ar { get; set; }
        public string title_en { get; set; }
        public int hadith_count { get; set; }
        public int start_id { get; set; }
        public int end_id { get; set; }
    }

    public static void Main(string[] args)
    {
        string workspace = AppDomain.CurrentDomain.BaseDirectory;
        if (args.Length > 0) workspace = args[0];
        else
        {
            // Traverse up if inside scripts/
            if (File.Exists(Path.Combine(workspace, "..", "book", "00_prologue_intention.md")))
                workspace = Path.GetFullPath(Path.Combine(workspace, ".."));
        }
        ExportAll(workspace);
    }

    public static void ExportAll(string workspaceDir)
    {
        string bookDir = Path.Combine(workspaceDir, "book");
        string dataDir = Path.Combine(workspaceDir, "data");
        string mobileDataDir = Path.Combine(workspaceDir, "mobile", "assets", "data");

        Directory.CreateDirectory(dataDir);
        Directory.CreateDirectory(mobileDataDir);

        string hadithsJsonFile = Path.Combine(dataDir, "hadiths.json");
        string chaptersJsonFile = Path.Combine(dataDir, "chapters.json");
        string mobileHadithsFile = Path.Combine(mobileDataDir, "hadiths.json");
        string mobileChaptersFile = Path.Combine(mobileDataDir, "chapters.json");

        string[] files = Directory.GetFiles(bookDir, "*.md");
        Array.Sort(files);

        List<HadithItem> allHadiths = new List<HadithItem>();
        List<ChapterItem> chaptersList = new List<ChapterItem>();

        foreach (string file in files)
        {
            string fileName = Path.GetFileName(file);
            string content = File.ReadAllText(file, Encoding.UTF8);

            int chapterId = 0;
            Match chNumMatch = Regex.Match(fileName, @"^(\d+)");
            if (chNumMatch.Success) chapterId = int.Parse(chNumMatch.Groups[1].Value);

            string chapterTitleAr = "";
            string chapterTitleEn = "";

            Match h2Match = Regex.Match(content, @"(?m)^##\s+(.+)");
            Match h3Match = Regex.Match(content, @"(?m)^###\s+(?:Chapter\s*\d+:|Prologue:)?\s*(.+)");

            if (chapterId == 0)
            {
                chapterTitleAr = "مُقَدِّمَةٌ فِي الْإِخْلَاصِ وَإِحْضَارِ النِّيَّةِ";
                chapterTitleEn = "Prologue: Sincerity & Rectification of Intention";
            }
            else
            {
                if (h2Match.Success) chapterTitleAr = h2Match.Groups[1].Value.Trim();
                if (h3Match.Success) chapterTitleEn = h3Match.Groups[1].Value.Trim();
            }

            string hadithPattern = @"(?ms)^###\s+(?:Hadith\s+#|\*\*Hadith\s*#|\*\*\u0627\u0644\u062d\u062f\u064a\u062b\s*\u0631\u0642\u0645:\s*)(\d{1,4}).*?\n(.*?)(?=^###\s+(?:Hadith|\*\*Hadith|\*\*\u0627\u0644\u062d\u062f\u064a\u062b)|\Z)";
            MatchCollection hadithMatches = Regex.Matches(content, hadithPattern);

            int chapterHadithCount = 0;
            int startId = 0;
            int endId = 0;

            foreach (Match hm in hadithMatches)
            {
                int hId = int.Parse(hm.Groups[1].Value);
                string block = hm.Groups[2].Value.Trim();

                if (startId == 0 || hId < startId) startId = hId;
                if (hId > endId) endId = hId;
                chapterHadithCount++;

                string topicAr = "";
                string topicEn = "";
                string arMatn = "";
                string narrAr = "";
                string narrEn = "";
                string enTrans = "";
                string takhrij = "";
                string grading = "";
                string benefitsAr = "";
                string benefitsEn = "";

                // Topics
                Match topArMatch = Regex.Match(block, @"(?m)\[(?:\u0627\u0644\u0628\u0627\u0628|\u0628\u0627\u0628):\s*(.+?)\]");
                if (topArMatch.Success) topicAr = Clean(topArMatch.Groups[1].Value);

                Match topEnMatch = Regex.Match(block, @"(?m)\[(?:Topic|Chapter):\s*(.+?)\]");
                if (topEnMatch.Success) topicEn = Clean(topEnMatch.Groups[1].Value);

                // Arabic Matn
                Match matnMatch1 = Regex.Match(block, @"(?ms)(?:\*\*\u0646\u064e\u0635\u064f\u0651\s*\u0627\u0644\u0652\u062d\u064e\u062f\u0650\u064a\u062b\u0650\s*\u0628\u0650\u0627\u0644\u062a\u064e\u0651\u0634\u0652\u0643\u0650\u064a\u0644\u0650:\*\*|#### \u0646\u064e\u0635\u064f\u0651\s*\u0627\u0644\u0652\u062d\u064e\u062f\u0650\u064a\u062b\u0650\s*\u0628\u0650\u0627\u0644\u062a\u064e\u0651\u0634\u0652\u0643\u0650\u064a\u0644\u0650)\s*\n*>\s*(.+?)(?=\n+\*\s*\*\*|\n+---|\n+####|</div>|\Z)");
                if (matnMatch1.Success)
                {
                    arMatn = CleanBlock(matnMatch1.Groups[1].Value);
                }
                else
                {
                    Match matnMatch2 = Regex.Match(block, @"(?ms)>\s*([\u0600-\u06FF\s\«\»\.\،\:\;\!\؟\(\)\-\""\'\d\–\—\…]+?)(?=\n+\*\s*\*\*|\n+---|\n+####|</div>|\Z)");
                    if (matnMatch2.Success) arMatn = CleanBlock(matnMatch2.Groups[1].Value);
                }

                // Narrators
                Match narrArM = Regex.Match(block, @"(?m)^\*\s*\*\*\u0627\u0644\u0631\u064e\u0651\u0627\u0648\u0650\u064a:\*\*\s*(.+?)$");
                if (narrArM.Success) narrAr = Clean(narrArM.Groups[1].Value);

                Match narrEnM = Regex.Match(block, @"(?m)(?:^\*\s*\*\*Companion Narrator:\*\*|#### \u0627\u0644\u0631\u064e\u0651\u0627\u0648\u0650\u064a\s*\(The Narrator\):\s*\n\*\*(?:Narrated by\s+)?)(.+?)(?:\*\*)?$");
                if (narrEnM.Success) narrEn = Clean(narrEnM.Groups[1].Value);

                // English Translation
                Match transMatch1 = Regex.Match(block, @"(?ms)(?:\*\*English Translation:?\*\*|#### \u0627\u0644\u062a\u064e\u0651\u0631\u0652\u062c\u064e\u0645\u064e\u0629\u064f\s*\u0627\u0644\u0625\u0650\u0646\u0652\u062c\u0650\u0644\u0650\u064a\u0632\u0650\u064a\u064e\u0651\u0629\u064f\s*\(English Translation\):?)\s*\n*(.+?)(?=\n+\*\s*\*\*|\n+<div|\n+---|---|\Z)");
                if (transMatch1.Success)
                {
                    string rawTrans = transMatch1.Groups[1].Value;
                    string[] transLines = rawTrans.Split('\n');
                    List<string> cleanT = new List<string>();
                    foreach (string tl in transLines)
                    {
                        string tTrim = tl.Trim();
                        if (tTrim.StartsWith("* **") || tTrim.StartsWith("####") || tTrim.StartsWith("#####") || tTrim.StartsWith("<div") || tTrim.StartsWith("</div"))
                            break;
                        tTrim = Regex.Replace(tTrim, @"^[>\s\*]+", "").Trim();
                        if (tTrim.Length > 0) cleanT.Add(tTrim);
                    }
                    enTrans = string.Join(" ", cleanT).Trim('\"', '\'', ' ', '“', '”', '*');
                }

                // References
                Match takhArM = Regex.Match(block, @"(?m)^\*\s*\*\*(?:\u0627\u0644\u062a\u064e\u0651\u062e\u0652\u0631\u0650\u064a\u062c\u064f|Source):\*\*\s*(.+?)$");
                if (takhArM.Success) takhrij = Clean(takhArM.Groups[1].Value);
                else
                {
                    Match refM = Regex.Match(block, @"(?m)^\*\s*\*\*Canonical Reference:\*\*\s*(.+?)$");
                    if (refM.Success) takhrij = Clean(refM.Groups[1].Value);
                }

                // Grading
                Match gradArM = Regex.Match(block, @"(?m)^\*\s*\*\*(?:\u0627\u0644\u0652\u062d\u064f\u0643\u0652\u0645\u064f|Scholarly Grading):\*\*\s*(.+?)$");
                if (gradArM.Success) grading = Clean(gradArM.Groups[1].Value);
                if (string.IsNullOrEmpty(grading)) grading = "صَحِيحٌ (Sahih)";

                // Benefits
                Match benArM = Regex.Match(block, @"(?ms)^\*\s*\*\*\u0627\u0644\u0652\u0641\u064e\u0648\u064e\u0627\u0626\u0650\u062f\u064f\s*\u0648\u064e\u0627\u0644\u0652\u0639\u0650\u0628\u064e\u0631\u064f:\*\*\s*\n*(.+?)(?=</div>|\n+####|\Z)");
                if (benArM.Success) benefitsAr = CleanBlock(benArM.Groups[1].Value);

                Match benEnM = Regex.Match(block, @"(?ms)(?:^\*\s*\*\*Key Lessons & Takeaways:\*\*|#### \u0627\u0644\u0652\u0641\u064e\u0648\u064e\u0627\u0626\u0650\u062f\u064f\s*\u0648\u064e\u0627\u0644\u0652\u0639\u0650\u0628\u064e\u0631\u064f\s*\(Key Takeaways & Reflections\):)\s*\n*(.+?)(?=---|---|\Z)");
                if (benEnM.Success) benefitsEn = CleanBlock(benEnM.Groups[1].Value);

                if (hId == 1)
                {
                    if (string.IsNullOrEmpty(topicAr)) topicAr = "إنما الأعمال بالنيات";
                    if (string.IsNullOrEmpty(topicEn)) topicEn = "Actions are judged only by intentions";
                    if (string.IsNullOrEmpty(narrAr)) narrAr = "أَمِيرُ الْمُؤْمِنِينَ عُمَرُ بْنُ الْخَطَّابِ رَضِيَ اللَّهُ عَنْهُ";
                    if (string.IsNullOrEmpty(narrEn)) narrEn = "Abu Hafs 'Umar ibn al-Khattab (RA)";
                    if (string.IsNullOrEmpty(takhrij)) takhrij = "صحيح البخاري (1)، صحيح مسلم (1907)";
                    if (string.IsNullOrEmpty(grading)) grading = "مُتَّفَقٌ عَلَيْهِ (صَحِيحٌ)";
                    if (string.IsNullOrEmpty(enTrans))
                    {
                        enTrans = "On the authority of Amir al-Mu'minin, Abu Hafs 'Umar ibn al-Khattab (RA), who said: I heard the Messenger of Allah ﷺ say: 'Actions are judged only by intentions, and every person will have only what they intended. So whoever emigrated for the sake of Allah and His Messenger, their emigration is for Allah and His Messenger; and whoever emigrated for some worldly gain or to take a woman in marriage, their emigration is for whatever they emigrated for.'";
                    }
                }

                allHadiths.Add(new HadithItem
                {
                    id = hId,
                    id_str = "#" + hId.ToString("D4"),
                    chapter_id = chapterId,
                    chapter_title_ar = chapterTitleAr,
                    chapter_title_en = chapterTitleEn,
                    topic_ar = topicAr,
                    topic_en = topicEn,
                    arabic_matn = arMatn,
                    narrator_ar = narrAr,
                    narrator_en = narrEn,
                    english_translation = enTrans,
                    takhrij = takhrij,
                    grading = grading,
                    benefits_ar = benefitsAr,
                    benefits_en = benefitsEn
                });
            }

            chaptersList.Add(new ChapterItem
            {
                id = chapterId,
                filename = fileName,
                title_ar = chapterTitleAr,
                title_en = chapterTitleEn,
                hadith_count = chapterHadithCount,
                start_id = startId,
                end_id = endId
            });
        }

        allHadiths.Sort((a, b) => a.id.CompareTo(b.id));

        string hadithsJsonContent = SerializeHadiths(allHadiths);
        string chaptersJsonContent = SerializeChapters(allHadiths.Count, chaptersList);

        File.WriteAllText(hadithsJsonFile, hadithsJsonContent, Encoding.UTF8);
        File.WriteAllText(chaptersJsonFile, chaptersJsonContent, Encoding.UTF8);

        File.WriteAllText(mobileHadithsFile, hadithsJsonContent, Encoding.UTF8);
        File.WriteAllText(mobileChaptersFile, chaptersJsonContent, Encoding.UTF8);

        Console.WriteLine("SUCCESSFULLY EXPORTED " + allHadiths.Count + " HADITHS ACROSS " + chaptersList.Count + " CHAPTERS!");
    }

    private static string SerializeHadiths(List<HadithItem> hadiths)
    {
        StringBuilder jsonSb = new StringBuilder();
        jsonSb.AppendLine("[\n");
        for (int i = 0; i < hadiths.Count; i++)
        {
            var h = hadiths[i];
            jsonSb.AppendLine("  {");
            jsonSb.AppendLine("    \"id\": " + h.id + ",");
            jsonSb.AppendLine("    \"id_str\": \"" + EscapeJson(h.id_str) + "\",");
            jsonSb.AppendLine("    \"chapter_id\": " + h.chapter_id + ",");
            jsonSb.AppendLine("    \"chapter_title_ar\": \"" + EscapeJson(h.chapter_title_ar) + "\",");
            jsonSb.AppendLine("    \"chapter_title_en\": \"" + EscapeJson(h.chapter_title_en) + "\",");
            jsonSb.AppendLine("    \"topic_ar\": \"" + EscapeJson(h.topic_ar) + "\",");
            jsonSb.AppendLine("    \"topic_en\": \"" + EscapeJson(h.topic_en) + "\",");
            jsonSb.AppendLine("    \"arabic_matn\": \"" + EscapeJson(h.arabic_matn) + "\",");
            jsonSb.AppendLine("    \"narrator_ar\": \"" + EscapeJson(h.narrator_ar) + "\",");
            jsonSb.AppendLine("    \"narrator_en\": \"" + EscapeJson(h.narrator_en) + "\",");
            jsonSb.AppendLine("    \"english_translation\": \"" + EscapeJson(h.english_translation) + "\",");
            jsonSb.AppendLine("    \"takhrij\": \"" + EscapeJson(h.takhrij) + "\",");
            jsonSb.AppendLine("    \"grading\": \"" + EscapeJson(h.grading) + "\",");
            jsonSb.AppendLine("    \"benefits_ar\": \"" + EscapeJson(h.benefits_ar) + "\",");
            jsonSb.AppendLine("    \"benefits_en\": \"" + EscapeJson(h.benefits_en) + "\"");
            jsonSb.Append("  }" + (i < hadiths.Count - 1 ? ",\n" : "\n"));
        }
        jsonSb.AppendLine("]");
        return jsonSb.ToString();
    }

    private static string SerializeChapters(int totalHadiths, List<ChapterItem> chapters)
    {
        StringBuilder chapSb = new StringBuilder();
        chapSb.AppendLine("{\n");
        chapSb.AppendLine("  \"book_title\": \"ألف حديث وحديث - 1001 Authentic Hadith\",");
        chapSb.AppendLine("  \"author\": \"Ibrahim Sharif Abubakar\",");
        chapSb.AppendLine("  \"author_ar\": \"إبراهيم شريف أبوبكر\",");
        chapSb.AppendLine("  \"compiler\": \"Ibrahim Sharif Abubakar\",");
        chapSb.AppendLine("  \"compiler_ar\": \"إبراهيم شريف أبوبكر\",");
        chapSb.AppendLine("  \"edition\": \"1st Complete Scholarly Edition\",");
        chapSb.AppendLine("  \"total_hadiths\": " + totalHadiths + ",");
        chapSb.AppendLine("  \"chapters_count\": " + chapters.Count + ",");
        chapSb.AppendLine("  \"chapters\": [");
        for (int i = 0; i < chapters.Count; i++)
        {
            var c = chapters[i];
            chapSb.AppendLine("    {");
            chapSb.AppendLine("      \"id\": " + c.id + ",");
            chapSb.AppendLine("      \"filename\": \"" + EscapeJson(c.filename) + "\",");
            chapSb.AppendLine("      \"arabic_title\": \"" + EscapeJson(c.title_ar) + "\",");
            chapSb.AppendLine("      \"english_title\": \"" + EscapeJson(c.title_en) + "\",");
            chapSb.AppendLine("      \"hadith_count\": " + c.hadith_count + ",");
            chapSb.AppendLine("      \"start_id\": " + c.start_id + ",");
            chapSb.AppendLine("      \"end_id\": " + c.end_id);
            chapSb.Append("    }" + (i < chapters.Count - 1 ? ",\n" : "\n"));
        }
        chapSb.AppendLine("  ]\n}");
        return chapSb.ToString();
    }

    private static string Clean(string input)
    {
        if (string.IsNullOrEmpty(input)) return "";
        string s = input.Trim();
        s = Regex.Replace(s, @"^\*+|\*+$", "").Trim();
        s = Regex.Replace(s, @"^\[+|\]+$", "").Trim();
        return s.Trim();
    }

    private static string CleanBlock(string input)
    {
        if (string.IsNullOrEmpty(input)) return "";
        string s = input.Trim();
        s = Regex.Replace(s, @"(?m)^\s*>\s*", "");
        s = Regex.Replace(s, @"^\*+|\*+$", "").Trim();
        return s.Trim();
    }

    private static string EscapeJson(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\")
                .Replace("\"", "\\\"")
                .Replace("\r", "")
                .Replace("\n", "\\n")
                .Replace("\t", "\\t");
    }
}
