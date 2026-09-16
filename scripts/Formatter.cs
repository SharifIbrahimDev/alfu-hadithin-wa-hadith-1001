using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;

public class HadithDualFormatter
{
    public static void ProcessDirectory(string bookDir)
    {
        string[] files = Directory.GetFiles(bookDir, "*.md");
        Array.Sort(files);

        int totalCount = 0;
        foreach (string file in files)
        {
            string fileName = Path.GetFileName(file);
            if (fileName == "00_prologue_intention.md")
            {
                Console.WriteLine("Skipping: " + fileName + " (already formatted)");
                totalCount += 1;
                continue;
            }

            int count = ProcessFile(file);
            totalCount += count;
        }

        Console.WriteLine("\n=================================");
        Console.WriteLine("TOTAL HADITHS FORMATTED: " + totalCount);
        Console.WriteLine("=================================");
    }

    public static int ProcessFile(string filePath)
    {
        string fileName = Path.GetFileName(filePath);
        string content = File.ReadAllText(filePath, Encoding.UTF8);

        // Match the first actual Hadith header (NOT "### Chapter" or "### Prologue")
        string hadithHeaderPattern = @"(?m)^###\s+(?:\*\*(?:\u0627\u0644\u062d\u062f\u064a\u062b\s*\u0631\u0642\u0645:|Hadith\s*#|#)|Hadith\s*#|\u0627\u0644\u062d\u062f\u064a\u062b\s*\u0631\u0642\u0645:|\#?\d{4})";
        Match firstMatch = Regex.Match(content, hadithHeaderPattern);
        if (!firstMatch.Success)
        {
            Console.WriteLine("No hadiths found in " + fileName);
            return 0;
        }

        string header = content.Substring(0, firstMatch.Index).Trim();
        string hadithsPart = content.Substring(firstMatch.Index);

        string[] chunks = Regex.Split(hadithsPart, @"(?m)^(?=###\s+(?:\*\*(?:\u0627\u0644\u062d\u062f\u064a\u062b\s*\u0631\u0642\u0645:|Hadith\s*#|#)|Hadith\s*#|\u0627\u0644\u062d\u062f\u064a\u062b\s*\u0631\u0642\u0645:|\#?\d{4}))");

        StringBuilder sb = new StringBuilder();
        sb.AppendLine(header);
        sb.AppendLine("\n---\n");

        int count = 0;
        foreach (string rawChunk in chunks)
        {
            string chunk = rawChunk.Trim();
            if (string.IsNullOrEmpty(chunk)) continue;

            Match numMatch = Regex.Match(chunk, @"^###\s+.*?(?:#|\u0631\u0642\u0645:\s*|Hadith\s*#?)?\s*(\d{1,4})");
            if (!numMatch.Success) continue;

            count++;
            int hNum = int.Parse(numMatch.Groups[1].Value);
            string hStr = hNum.ToString("D4");

            string arTopic = "";
            string enTopic = "";
            string arMatn = "";
            string narratorAr = "";
            string narratorEn = "";
            string enTrans = "";
            string takhrij = "";
            string grading = "";
            string benefitsAr = "";
            string benefitsEn = "";

            // Topics
            Match arTopMatch = Regex.Match(chunk, @"(?m)\[(?:\u0627\u0644\u0628\u0627\u0628|\u0628\u0627\u0628):\s*(.+?)\]");
            if (arTopMatch.Success) arTopic = Clean(arTopMatch.Groups[1].Value);

            Match enTopMatch = Regex.Match(chunk, @"(?m)\[Topic:\s*(.+?)\]");
            if (enTopMatch.Success) enTopic = Clean(enTopMatch.Groups[1].Value);

            if (string.IsNullOrEmpty(arTopic) || string.IsNullOrEmpty(enTopic))
            {
                Match topChapMatch = Regex.Match(chunk, @"(?m)Topic\s*/\s*Chapter:\s*(.+?)$");
                if (topChapMatch.Success)
                {
                    string rawTop = Clean(topChapMatch.Groups[1].Value);
                    if (rawTop.Contains("/"))
                    {
                        string[] parts = rawTop.Split(new char[] { '/' }, 2);
                        if (string.IsNullOrEmpty(enTopic)) enTopic = Clean(parts[0]);
                        if (string.IsNullOrEmpty(arTopic)) arTopic = Clean(parts[1]);
                    }
                    else if (string.IsNullOrEmpty(enTopic))
                    {
                        enTopic = rawTop;
                    }
                }
            }

            Match subMatch = Regex.Match(chunk, @"(?m)Sub-topic:\s*(.+?)$");
            if (subMatch.Success)
            {
                string rawSub = Clean(subMatch.Groups[1].Value);
                if (rawSub.Contains("/"))
                {
                    string[] parts = rawSub.Split(new char[] { '/' }, 2);
                    enTopic = string.IsNullOrEmpty(enTopic) ? Clean(parts[0]) : enTopic + " — " + Clean(parts[0]);
                    arTopic = string.IsNullOrEmpty(arTopic) ? Clean(parts[1]) : arTopic + " — " + Clean(parts[1]);
                }
                else
                {
                    enTopic = string.IsNullOrEmpty(enTopic) ? rawSub : enTopic + " — " + rawSub;
                }
            }

            // Arabic Matn
            Match matnMatch1 = Regex.Match(chunk, @"(?ms)(?:\u0646\u064e\u0635\u064f\u0651\s*\u0627\u0644\u0652\u062d\u064e\u062f\u0650\u064a\u062b\u0650|\u0646\u0635\s*\u0627\u0644\u062d\u062f\u064a\u062b|Arabic Matn)[^:]*:\s*\n*(.+?)(?=\n+\s*\*?\s*\**\[?(?:\u0627\u0644\u0631\u064e\u0651\u0627\u0648\u0650\u064a|\u0627\u0644\u0631\u0627\u0648\u064a|Narrator|English Translation))");
            if (matnMatch1.Success)
            {
                arMatn = CleanBlock(matnMatch1.Groups[1].Value);
            }
            else
            {
                Match matnMatch2 = Regex.Match(chunk, @"(?ms)>\s*([\u0600-\u06FF\s\«\»\.\،\:\;\!\؟\(\)\-\""\'\d\–]+?)(?=\n+\s*\*?\s*\**\[?(?:\u0627\u0644\u0631\u064e\u0651\u0627\u0648\u0650\u064a|\u0627\u0644\u0631\u0627\u0648\u064a|Narrator|English Translation))");
                if (matnMatch2.Success) arMatn = CleanBlock(matnMatch2.Groups[1].Value);
            }

            // Narrator
            Match narrArMatch = Regex.Match(chunk, @"(?m)(?:\u0627\u0644\u0631\u064e\u0651\u0627\u0648\u0650\u064a|\u0627\u0644\u0631\u0627\u0648\u064a)[^:]*:\s*(.+?)$");
            if (narrArMatch.Success) narratorAr = Clean(narrArMatch.Groups[1].Value);

            Match narrEnMatch = Regex.Match(chunk, @"(?m)Narrator[^:]*:\s*(.+?)$");
            if (narrEnMatch.Success) narratorEn = Clean(narrEnMatch.Groups[1].Value);

            // English Translation
            Match transMatch = Regex.Match(chunk, @"(?ms)English Translation[^:]*:\s*\n*(.+?)(?=\n+\s*\*?\s*\**\[?(?:\u0627\u0644\u062a\u064e\u0651\u062e\u0652\u0631\u0650\u064a\u062c\u064f|\u0627\u0644\u062a\u062e\u0631\u064a\u062c|Reference|\u0627\u0644\u0652\u062d\u064f\u0643\u0652\u0645\u064f|\u0627\u0644\u062d\u0643\u0645|Grading|\Z))");
            if (transMatch.Success)
            {
                enTrans = CleanBlock(transMatch.Groups[1].Value);
                enTrans = enTrans.Trim('\"', '\'', '“', '”').Trim();
            }

            // Takhrij
            Match takhMatch = Regex.Match(chunk, @"(?m)(?:\u0627\u0644\u062a\u064e\u0651\u062e\u0652\u0631\u0650\u064a\u062c\u064f|\u0627\u0644\u062a\u062e\u0631\u064a\u062c)[^:]*:\s*(.+?)$");
            if (takhMatch.Success) takhrij = Clean(takhMatch.Groups[1].Value);
            else
            {
                Match refMatch = Regex.Match(chunk, @"(?m)Reference(?:\s*&\s*Grading)?[^:]*:\s*(.+?)$");
                if (refMatch.Success) takhrij = Clean(refMatch.Groups[1].Value);
            }

            // Grading
            Match gradMatch = Regex.Match(chunk, @"(?m)(?:\u0627\u0644\u0652\u062d\u064f\u0643\u0652\u0645\u064f|\u0627\u0644\u062d\u0643\u0645)[^:]*:\s*(.+?)$");
            if (gradMatch.Success) grading = Clean(gradMatch.Groups[1].Value);
            else
            {
                Match gradEnMatch = Regex.Match(chunk, @"(?m)Grading[^:]*:\s*(.+?)$");
                if (gradEnMatch.Success) grading = Clean(gradEnMatch.Groups[1].Value);
            }
            if (string.IsNullOrEmpty(grading)) grading = "\u0635\u064e\u062d\u0650\u064a\u062d\u064c (Sahih)";

            // Benefits
            Match benArMatch = Regex.Match(chunk, @"(?ms)(?:\u0627\u0644\u0652\u0641\u064e\u0648\u064e\u0627\u0626\u0650\u062f\u064f|\u0627\u0644\u0641\u0648\u0627\u0626\u062f)[^:]*:\s*\n*(.+?)(?=\n---|\Z)");
            if (benArMatch.Success) benefitsAr = CleanBlock(benArMatch.Groups[1].Value);

            Match benEnMatch = Regex.Match(chunk, @"(?ms)(?:Key Benefit|Key Lessons)[^:]*:\s*\n*(.+?)(?=\n---|\Z)");
            if (benEnMatch.Success) benefitsEn = CleanBlock(benEnMatch.Groups[1].Value);

            // Assemble Dual Section Output
            sb.AppendLine("### Hadith #" + hStr + " | \u0627\u0644\u062d\u062f\u064a\u062b \u0631\u0642\u0645: " + hStr + "\n");

            // 🇸🇦 Arabic Section (RTL)
            sb.AppendLine("#### 🇸🇦 \u0627\u0644\u0642\u0633\u0645 \u0627\u0644\u0639\u0631\u0628\u064a (Arabic Text & Takhrij)");
            sb.AppendLine("<div dir=\"rtl\" align=\"right\">\n");

            if (!string.IsNullOrEmpty(arTopic))
                sb.AppendLine("##### **[\u0627\u0644\u0628\u0627\u0628: " + arTopic + "]**\n");

            if (!string.IsNullOrEmpty(arMatn))
                sb.AppendLine("> **\u0646\u064e\u0635\u064f\u0651 \u0627\u0644\u0652\u062d\u064e\u062f\u0650\u064a\u062b\u0650 \u0628\u0650\u0627\u0644\u062a\u064e\u0651\u0634\u0652\u0643\u0650\u064a\u0644\u0650:**  \n> " + arMatn + "\n");

            if (!string.IsNullOrEmpty(narratorAr))
                sb.AppendLine("* **\u0627\u0644\u0631\u064e\u0651\u0627\u0648\u0650\u064a:** " + narratorAr);

            if (!string.IsNullOrEmpty(takhrij))
                sb.AppendLine("* **\u0627\u0644\u062a\u064e\u0651\u062e\u0652\u0631\u0650\u064a\u062c\u064f:** " + takhrij);

            if (!string.IsNullOrEmpty(grading))
                sb.AppendLine("* **\u0627\u0644\u0652\u062d\u064f\u0643\u0652\u0645\u064f:** " + grading);

            if (!string.IsNullOrEmpty(benefitsAr))
                sb.AppendLine("* **\u0627\u0644\u0652\u0641\u064e\u0648\u064e\u0627\u0626\u0650\u062f\u064f \u0648\u064e\u0627\u0644\u0652\u0639\u0650\u0628\u064e\u0631\u064f:**\n" + benefitsAr);

            sb.AppendLine("\n</div>\n");

            // 🇬🇧 English Section (LTR)
            sb.AppendLine("#### 🇬🇧 English Translation & Commentary");

            if (!string.IsNullOrEmpty(enTopic))
                sb.AppendLine("##### **[Topic: " + enTopic + "]**\n");

            if (!string.IsNullOrEmpty(enTrans))
                sb.AppendLine("> **English Translation:**  \n> *\"" + enTrans + "\"*\n");

            if (!string.IsNullOrEmpty(narratorEn))
                sb.AppendLine("* **Companion Narrator:** " + narratorEn);
            else if (!string.IsNullOrEmpty(narratorAr))
                sb.AppendLine("* **Companion Narrator:** " + narratorAr);

            if (!string.IsNullOrEmpty(takhrij))
                sb.AppendLine("* **Canonical Reference:** " + takhrij);

            if (!string.IsNullOrEmpty(grading))
                sb.AppendLine("* **Scholarly Grading:** **" + grading.TrimEnd('.') + "**");

            if (!string.IsNullOrEmpty(benefitsEn))
                sb.AppendLine("* **Key Lessons & Takeaways:** " + benefitsEn);

            sb.AppendLine("\n---\n");
        }

        string result = sb.ToString().Trim() + "\n";
        File.WriteAllText(filePath, result, Encoding.UTF8);
        Console.WriteLine("Successfully formatted " + fileName + " (" + count + " Hadiths)");
        return count;
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
}
