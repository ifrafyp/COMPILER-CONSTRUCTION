using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace MiniCompiler
{
    class Program
    {
        static void Main(string[] args)
        {
            // Sample input: variable assignments
            string[] lines = {
                "int a = 5;",
                "int b = a + 3;",
                "int c = b * 2;"
            };

            // Build symbol table (varName -> address)
            var symbolTable = new Dictionary<string, int>();
            int nextAddress = 0;

            // For simplicity: just collect variables in order
            foreach (var line in lines)
            {
                var varMatch = Regex.Match(line, @"int\s+(\w+)\s*=");
                if (varMatch.Success)
                {
                    string varName = varMatch.Groups[1].Value;
                    if (!symbolTable.ContainsKey(varName))
                        symbolTable[varName] = nextAddress++;
                }
            }

            Console.WriteLine("--- Symbol Table ---");
            foreach (var kvp in symbolTable)
                Console.WriteLine($"{kvp.Key} => Address {kvp.Value}");

            Console.WriteLine("\n--- Generated Stack Machine Code ---");
            foreach (var line in lines)
            {
                var code = GenerateCode(line, symbolTable);
                foreach (var instruction in code)
                    Console.WriteLine(instruction);
            }
        }

        // Generate stack-based code for one assignment line
        static List<string> GenerateCode(string line, Dictionary<string, int> symbolTable)
        {
            var instructions = new List<string>();

            // Parse line like: int var = expr;
            var match = Regex.Match(line, @"int\s+(\w+)\s*=\s*(.+);");
            if (!match.Success)
                throw new Exception("Invalid syntax: " + line);

            string varName = match.Groups[1].Value;
            string expr = match.Groups[2].Value.Trim();

            // Parse expression (support var, const, var+const, var*const, etc.)
            // Very simple parsing here for demo purposes:
            var binOpMatch = Regex.Match(expr, @"(\w+|\d+)\s*([\+\-\*/])\s*(\w+|\d+)");
            if (binOpMatch.Success)
            {
                string left = binOpMatch.Groups[1].Value;
                string op = binOpMatch.Groups[2].Value;
                string right = binOpMatch.Groups[3].Value;

                // Load left operand
                if (int.TryParse(left, out int leftVal))
                    instructions.Add($"PUSH {leftVal}");
                else
                {
                    int addr = symbolTable[left];
                    instructions.Add($"LOAD {addr}");
                }

                // Load right operand
                if (int.TryParse(right, out int rightVal))
                    instructions.Add($"PUSH {rightVal}");
                else
                {
                    int addr = symbolTable[right];
                    instructions.Add($"LOAD {addr}");
                }

                // Operation
                instructions.Add(op switch
                {
                    "+" => "ADD",
                    "-" => "SUB",
                    "*" => "MUL",
                    "/" => "DIV",
                    _ => throw new Exception("Unknown operator " + op)
                });
            }
            else
            {
                // Single operand expression (variable or constant)
                if (int.TryParse(expr, out int val))
                    instructions.Add($"PUSH {val}");
                else
                {
                    int addr = symbolTable[expr];
                    instructions.Add($"LOAD {addr}");
                }
            }

            // Store result in variable address
            instructions.Add($"STORE {symbolTable[varName]}");

            return instructions;
        }
    }
}
