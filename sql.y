%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Prototipos */
void yyerror(const char *s);
int yylex(void);

/* -------------------------------------------------- */
/* Función auxiliar para concatenar tres cadenas       */
/* -------------------------------------------------- */
char* concat3(const char *s1, const char *s2, const char *s3) {
    size_t len = strlen(s1) + strlen(s2) + strlen(s3) + 1;
    char *r = (char*)malloc(len);
    if (!r) {
        fprintf(stderr, "Error de memoria en concat3\n");
        exit(EXIT_FAILURE);
    }
    strcpy(r, s1);
    strcat(r, s2);
    strcat(r, s3);
    return r;
}
%}

/* -------------------------------------------------- */
/* Definiciones de tipos para valores semánticos      */
/* -------------------------------------------------- */
%union {
    int    ival;   /* para token NUMERO */
    char*  sval;   /* para IDENTIFICADOR, CADENA, lista_valores, valor */
}

/* -------------------------------------------------- */
/* Definición de tokens y su asociación a <union>     */
/* -------------------------------------------------- */
%token <sval> IDENTIFICADOR CADENA
%token <ival> NUMERO

%token INSERTAR EN VALORES SELECCIONAR DE DONDE TODOS
%token ACTUALIZAR ESTABLECER A SI ELIMINAR
%token ES IGUAL MAYOR MENOR DISTINTO NO QUE Y O

%token PAR_ABRE PAR_CIERRA COMA
%token EOL

/* -------------------------------------------------- */
/* QUITAMOS el tipo <sval> de “campos” porque no lo usamos */
/* -------------------------------------------------- */
%type <sval> campos lista_campos lista_valores condicion valor operador


/* -------------------------------------------------- */
/* Precedencia y asociatividad para Y (AND) y O (OR)   */
/* -------------------------------------------------- */
%left O
%left Y

%%

/* ================================================== */
/*                 Sección de Gramática               */
/* ================================================== */

/* Punto de entrada: pueden haber varias sentencias seguidas */
entrada:
      /* línea vacía o EOF: nada que hacer */
    | entrada sentencia EOL
    ;

/* Una sentencia es cualquiera de los cuatro comandos SQL */
sentencia:
    insercion
    | seleccion
    | actualizacion
    | eliminacion
    ;

/* ------ Inserción ------ */
insercion:
    INSERTAR EN IDENTIFICADOR VALORES PAR_ABRE lista_valores PAR_CIERRA
    {
        /* $3 = IDENTIFICADOR (nombre de la tabla)
           $6 = lista_valores (string con "val1, val2, ...") */
        printf("INSERT INTO %s VALUES (%s);\n", $3, $6);
        free($6);
    }
    |
    INSERTAR EN IDENTIFICADOR PAR_ABRE lista_campos PAR_CIERRA VALORES PAR_ABRE lista_valores PAR_CIERRA
    {
        /* $3 = IDENTIFICADOR (nombre de la tabla)
           $6 = lista_valores (string con "val1, val2, ...") */
        printf("INSERT INTO %s (%s) VALUES (%s);\n", $3, $5, $9);
        free($5);
        free($9);
    }
	
    ;

/* ------ Selección (SELECT) ------ */
seleccion:
    SELECCIONAR campos DE IDENTIFICADOR
    {
        printf("SELECT %s FROM %s;\n", $2, $4);
    }
    |
    SELECCIONAR campos DE IDENTIFICADOR DONDE condicion
    {
        printf("SELECT %s FROM %s WHERE %s;\n", $2, $4, $6);
    }
    ;

/* “campos” puede ser TODOS o una lista de identificadores */
campos:
    TODOS          
    {
        $$ = strdup("*");
    }
    | lista_campos
    ;

/* “lista_campos” es simplemente IDENTIFICADOR (',' IDENTIFICADOR)* */
lista_campos:
    IDENTIFICADOR          { $$ = strdup($1); }
    | lista_campos COMA IDENTIFICADOR  
    { 
        char* temp = concat3($1, ", ", $3);
        free($1);
        $$ = temp;
    }
    ;

/* ------ Valores para INSERTAR ------ */
/* Cada valor produce un <sval>, y lista_valores va concatenando */
lista_valores:
    valor                  
    { 
        /* primer elemento: simplemente lo heredamos */
        $$ = $1;  
    }
    | lista_valores COMA valor    
    {
        /* Concatenamos: lista_valores previas + ", " + este valor */
        char *tmp = concat3($1, ", ", $3);
        free($1);
        free($3);
        $$ = tmp;
    }
    ;

/* Un “valor” puede ser número o cadena; devolvemos un string en $$ */
valor:
    NUMERO   
    {
        /* Convertimos el número en string */
        char buf[32];
        snprintf(buf, sizeof(buf), "%d", $1);
        $$ = strdup(buf);
    }
    | CADENA   
    {
        /* Añadimos comillas simples alrededor de la cadena */
        size_t len = strlen($1);
        /* +3: 2 comillas + \0 */
        char *tmp = (char*)malloc(len + 3);
        if (!tmp) {
            fprintf(stderr, "Error de memoria al procesar CADENA\n");
            exit(EXIT_FAILURE);
        }
        sprintf(tmp, "'%s'", $1);
        free($1);
        $$ = tmp;
    }
    ;

/* ------ Actualización (UPDATE) ------ */
actualizacion:
    ACTUALIZAR IDENTIFICADOR ESTABLECER IDENTIFICADOR A valor
    {
        printf("UPDATE '%s' SET '%s' en tabla;\n", $2, $4);
    }
    |
    ACTUALIZAR IDENTIFICADOR ESTABLECER IDENTIFICADOR A valor DONDE condicion
    {
        printf("Comando ACTUALIZAR con condición en tabla '%s';\n", $2);
    }
    ;

/* ------ Eliminación (DELETE) ------ */
eliminacion:
    ELIMINAR DE IDENTIFICADOR
    {
        printf("DELETE FROM %s;\n", $3);
    }
    |
    ELIMINAR DE IDENTIFICADOR DONDE condicion
    {
        printf("DELETE FROM %s WHERE %s;\n", $3, $5);
    }
    ;

/* ------ Condiciones con AND/OR ------ */
condicion:
    IDENTIFICADOR operador valor         
    {
        char *tmp = concat3($1, " ", $2);
        char *res = concat3(tmp, " ", $3);
        free(tmp); free($1); free($2); free($3);
        $$ = res;
    }
    | condicion Y condicion                 
    {
        char *tmp = concat3($1, " AND ", $3);
        free($1); free($3);
        $$ = tmp;
    }
    | condicion O condicion                 
    {
        char *tmp = concat3($1, " OR ", $3);
        free($1); free($3);
        $$ = tmp;
    }
    ;

/* Operadores básicos (=, >, <) */
operador: 
    IGUAL           { $$ = strdup("="); }
    | MAYOR         { $$ = strdup(">"); }
    | MENOR         { $$ = strdup("<"); }
    | MAYOR IGUAL   { $$ = strdup(">="); }
    | MENOR IGUAL   { $$ = strdup("<="); }
    | DISTINTO      { $$ = strdup("!="); }
    | NO IGUAL      { $$ = strdup("!="); }
    ;

%%

/* -------------------------------------------------- */
/* Función de error                                   */
/* -------------------------------------------------- */
void yyerror(const char *s) {
    fprintf(stderr, "Error sintáctico: %s\n", s);
}

/* -------------------------------------------------- */
/* Función main (opcional)                            */
/* -------------------------------------------------- */
int main() {
//    printf("Ingrese una instrucción SQL en español (CTRL+D para salir):\n");
    yyparse();
    return 0;
}
