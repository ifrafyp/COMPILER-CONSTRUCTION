using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace MiniCompiler
{
    class Program
    {
        static void Main(string[] args)
        {
            List<string> inputLines = new()
            {
                "int a = 2 + 3;",
                "int b = a * 4;",
                "int unused = 5 + 5;",   // This should be removed
                "int c = b + 10;"
            };

            Console.WriteLine("---- Original Code ----");
            foreach (var line in inputLines)
                Console.WriteLine(line);

            // Step 1: Apply Constant Folding
            var foldedLines = new List<string>();
            foreach (var line in inputLines)
                foldedLines.Add(FoldConstants(line));

            // Step 2: Dead Code Elimination (mock usage analysis)
            var usedVariables = new List<string> { "a", "b", "c" }; // assume these are used
            var optimizedLines = EliminateDeadCode(foldedLines, usedVariables);

            Console.WriteLine("\n---- Optimized Code ----");
            foreach (var line in optimizedLines)
                Console.WriteLine(line);
        }

        // Constant folding: evaluates basic math expressions in assignments
        static string FoldConstants(string line)
        {
            var match = Regex.Match(line, @"int\s+(\w+)\s*=\s*(\d+)\s*([\+\-\*/])\s*(\d+);");
            if (match.Success)
            {
                string varName = match.Groups[1].Value;
                int left = int.Parse(match.Groups[2].Value);
                string op = match.Groups[3].Value;
                int right = int.Parse(match.Groups[4].Value);

                int result = op switch
                {
                    "+" => left + right,
                    "-" => left - right,
                    "*" => left * right,
                    "/" => right != 0 ? left / right : 0,
                    _ => 0
                };

                return $"int {varName} = {result};";
            }

            return line; // return unchanged if not constant expression
        }

        // Removes lines that declare variables not in the 'used' list
        static List<string> EliminateDeadCode(List<string> lines, List<string> usedVariables)
        {
            var result = new List<string>();
            foreach (var line in lines)
            {
                var match = Regex.Match(line, @"int\s+(\w+)\s*=");
                if (match.Success)
                {
                    string varName = match.Groups[1].Value;
                    if (!usedVariables.Contains(varName))
                        continue; // skip dead code
                }
                result.Add(line);
            }
            return result;
        }
    }
}
