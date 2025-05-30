using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace MiniCompiler
{
    // Represents a compilation error with line number and message
    public class CompileError
    {
        public int LineNumber { get; }
        public string Message { get; }

        public CompileError(int lineNumber, string message)
        {
            LineNumber = lineNumber;
            Message = message;
        }

        public override string ToString()
        {
            return $"Error on line {LineNumber}: {Message}";
        }
    }

    public class ErrorHandler
    {
        private readonly List<CompileError> errors = new();

        // Add a new error
        public void AddError(int lineNumber, string message)
        {
            errors.Add(new CompileError(lineNumber, message));
        }

        // Check if any errors recorded
        public bool HasErrors()
        {
            return errors.Count > 0;
        }

        // Print all errors
        public void PrintErrors()
        {
            foreach (var error in errors)
                Console.WriteLine(error);
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            string[] sourceCode = {
                "int a = 5;",
                "int b = a + ;",          // Syntax error: incomplete expression
                "int c = d + 2;",         // Semantic error: d undefined
                "int 1x = 10;",           // Syntax error: invalid variable name
            };

            var errorHandler = new ErrorHandler();
            var definedVariables = new HashSet<string>();

            for (int i = 0; i < sourceCode.Length; i++)
            {
                string line = sourceCode[i].Trim();
                int lineNumber = i + 1;

                // Syntax check: simple pattern for 'int var = expr;'
                var match = Regex.Match(line, @"^int\s+([a-zA-Z_]\w*)\s*=\s*(.+);$");
                if (!match.Success)
                {
                    errorHandler.AddError(lineNumber, "Syntax error: invalid declaration or missing semicolon.");
                    continue;
                }

                string varName = match.Groups[1].Value;
                string expr = match.Groups[2].Value;

                // Semantic check: variable name must not start with digit (already ensured by regex)
                // Semantic check: expression must not be empty
                if (string.IsNullOrWhiteSpace(expr))
                {
                    errorHandler.AddError(lineNumber, "Syntax error: expression expected after '='.");
                    continue;
                }

                // Semantic check: all variables used in expression must be defined
                var varsInExpr = ExtractVariables(expr);
                foreach (var v in varsInExpr)
                {
                    if (!definedVariables.Contains(v) && !int.TryParse(v, out _))
                    {
                        errorHandler.AddError(lineNumber, $"Semantic error: variable '{v}' is not defined.");
                    }
                }

                // If no error for this line so far, add variable to defined set
                if (!errorHandler.HasErrors() || errorHandler.HasErrors() && !errorHandler.ToString().Contains($"line {lineNumber}"))
                {
                    definedVariables.Add(varName);
                }
            }

            if (errorHandler.HasErrors())
            {
                Console.WriteLine("Compilation failed with errors:");
                errorHandler.PrintErrors();
            }
            else
            {
                Console.WriteLine("Compilation succeeded with no errors.");
            }
        }

        // Extract variable names from a simple expression (alphanumeric words that are not numbers)
        static List<string> ExtractVariables(string expr)
        {
            var vars = new List<string>();
            var tokens = Regex.Matches(expr, @"[a-zA-Z_]\w*");

            foreach (Match t in tokens)
                vars.Add(t.Value);

            return vars;
        }
    }
}
