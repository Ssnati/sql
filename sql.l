%{
#include <stdio.h>
#include <string.h>
#include "sql.tab.h"


%}

%option noyywrap
%option yylineno

%%


"insertar"|"agregar"|"añadir"|"introducir"|"ingresar"      { return INSERTAR; }
"en"            { return EN; }
"valores"       { return VALORES; }
"seleccionar"|"leer"|"revisar"|"ver"|"mostrar"   { return SELECCIONAR; }
"de"            { return DE; }
"donde"         { return DONDE; }
"todos"         { return TODOS; }
"actualizar"|"cambiar"|"alterar"|"modificar"    { return ACTUALIZAR; }
"establecer"    { return ESTABLECER; }
"a"             { return A; }
"si"            { return SI; }
"eliminar"|"borrar"|"quitar"|"remover"|"retirar"      { return ELIMINAR; }
"es"            { return ES; }
"igual"         { return IGUAL; }
"mayor"         { return MAYOR; }
"menor"         { return MENOR; }
"que"           { return QUE; }
"y"             { return Y; }
"o"             { return O; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.sval = strdup(yytext);
    return IDENTIFICADOR;
}


\'[^\']*\' {
     yylval.sval = strdup(yytext + 1);
    yylval.sval[strlen(yylval.sval) - 1] = '\0';
    return CADENA;
}


[0-9]+ {
    yylval.ival = atoi(yytext);
    return NUMERO;
}


"("             { return PAR_ABRE; }
")"             { return PAR_CIERRA; }
","             { return COMA; }


[ \t\n]+        { /* Ignorar */ }


.               {
    fprintf(stderr, "Error léxico en línea %d: Carácter inesperado '%s'\n", yylineno, yytext);

}

%%
