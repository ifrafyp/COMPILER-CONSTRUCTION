using System;
using System.Collections.Generic;

namespace MiniCompiler
{
    // Represents a symbol (variable)
    public class Symbol
    {
        public string Name { get; }
        public string Type { get; }
        public string Scope { get; }
        public int Address { get; }

        public Symbol(string name, string type, string scope, int address)
        {
            Name = name;
            Type = type;
            Scope = scope;
            Address = address;
        }

        public override string ToString()
        {
            return $"Name: {Name}, Type: {Type}, Scope: {Scope}, Address: {Address}";
        }
    }

    // Symbol table manages all symbols with scope support
    public class SymbolTable
    {
        private readonly Dictionary<string, List<Symbol>> symbolsByName;
        private int nextAddress = 0;

        public SymbolTable()
        {
            symbolsByName = new Dictionary<string, List<Symbol>>();
        }

        // Adds a variable symbol to the table
        public Symbol AddSymbol(string name, string type, string scope)
        {
            var symbol = new Symbol(name, type, scope, nextAddress++);
            if (!symbolsByName.ContainsKey(name))
                symbolsByName[name] = new List<Symbol>();

            symbolsByName[name].Add(symbol);
            return symbol;
        }

        // Lookup symbol by name and scope hierarchy (closest scope first)
        public Symbol Lookup(string name, List<string> scopeHierarchy)
        {
            if (!symbolsByName.ContainsKey(name))
                return null;

            var candidates = symbolsByName[name];
            // Find symbol whose scope matches the nearest in scopeHierarchy
            foreach (var scope in scopeHierarchy)
            {
                var symbol = candidates.Find(s => s.Scope == scope);
                if (symbol != null)
                    return symbol;
            }

            return null;
        }

        // Print all symbols
        public void PrintAll()
        {
            Console.WriteLine("Symbol Table:");
            foreach (var list in symbolsByName.Values)
            {
                foreach (var symbol in list)
                    Console.WriteLine(symbol);
            }
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            var symbolTable = new SymbolTable();

            // Simulate scopes, e.g. "global", "function1", "function1.innerBlock"
            string globalScope = "global";
            string funcScope = "global.function1";

            // Add variables in global scope
            symbolTable.AddSymbol("x", "int", globalScope);
            symbolTable.AddSymbol("y", "float", globalScope);

            // Add variables in function scope
            symbolTable.AddSymbol("x", "int", funcScope); // shadows global x
            symbolTable.AddSymbol("z", "string", funcScope);

            // Lookup variables with scope hierarchy (closest first)
            List<string> currentScope = new() { funcScope, globalScope };

            Console.WriteLine("Lookup 'x':");
            var symX = symbolTable.Lookup("x", currentScope);
            Console.WriteLine(symX);

            Console.WriteLine("Lookup 'y':");
            var symY = symbolTable.Lookup("y", currentScope);
            Console.WriteLine(symY);

            Console.WriteLine("Lookup 'z':");
            var symZ = symbolTable.Lookup("z", currentScope);
            Console.WriteLine(symZ);

            Console.WriteLine("\nFull Symbol Table:");
            symbolTable.PrintAll();
        }
    }
}
