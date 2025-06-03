bison -d sql.y
flex sql.l
gcc sql.tab.c lex.yy.c -o sql -lfl
