#!/bin/bash
flex ICG_Scanner.l
yacc -dy ICG_Parser.y
gcc y.tab.c -w -o a
a test.c