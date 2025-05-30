#!/bin/bash
flex SemanticScanner.l
yacc -dy SemanticParser.y
gcc y.tab.c -w -o a
a test.c
