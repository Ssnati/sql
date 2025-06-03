%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Prototipos */
void yyerror(const char *s);
int yylex(void);
%}

/* -------------------------------------------------- */
/* Definiciones de tipos para valores semánticos      */
/* -------------------------------------------------- */
%union {
    int    ival;   /* para token NUMERO */
    char*  sval;   /* para IDENTIFICADOR y CADENA */
}

/* -------------------------------------------------- */
/* Definición de tokens y su asociación a <union>     */
/* -------------------------------------------------- */
%token <sval> IDENTIFICADOR CADENA
%token <ival> NUMERO

%token INSERTAR EN VALORES SELECCIONAR DE DONDE TODOS
%token ACTUALIZAR ESTABLECER A SI ELIMINAR
%token ES IGUAL MAYOR MENOR QUE Y O

%token PAR_ABRE PAR_CIERRA COMA

/* -------------------------------------------------- */
/* QUITAMOS el tipo <sval> de “campos” porque no lo usamos */
/* -------------------------------------------------- */
/* %type <sval> campos lista_campos lista_valores condicion */

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
    | entrada sentencia '\n'
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
        printf("INSERT INTO '%s' VALUES ()\n", $3);
    }
    ;

/* ------ Selección (SELECT) ------ */
seleccion:
    SELECCIONAR campos DE IDENTIFICADOR
    {
        printf("Comando SELECCIONAR campos de tabla '%s'\n", $4);
    }
  |
    SELECCIONAR campos DE IDENTIFICADOR DONDE condicion
    {
        printf("Comando SELECCIONAR con condición en tabla '%s'\n", $4);
    }
    ;

/* “campos” puede ser TODOS o una lista de identificadores */
campos:
      TODOS           /* aquí ya no declaramos valor semántico */
    | lista_campos
    ;

/* “lista_campos” es simplemente IDENTIFICADOR (',' IDENTIFICADOR)* */
lista_campos:
      IDENTIFICADOR          { /* no propagamos nada */ }
    | lista_campos COMA IDENTIFICADOR  { /* tampoco */ }
    ;

/* ------ Valores para INSERTAR ------ */
lista_valores:
      valor                  { /* vacío */ }
    | lista_valores COMA valor    { /* vacío */ }
    ;

/* Un “valor” puede ser número o cadena; dejamos acción vacía */
valor:
      NUMERO   { /* vacío */ }
    | CADENA   { /* vacío */ }
    ;

/* ------ Actualización (UPDATE) ------ */
actualizacion:
      ACTUALIZAR IDENTIFICADOR ESTABLECER IDENTIFICADOR A valor
    {
        printf("UPDATE '%s' SET '%s'n tabla '\n", $2, $4);
    }
  |
      ACTUALIZAR IDENTIFICADOR ESTABLECER IDENTIFICADOR A valor DONDE condicion
    {
        printf("Comando ACTUALIZAR con condición en tabla '%s'\n", $2);
    }
    ;

/* ------ Eliminación (DELETE) ------ */
eliminacion:
      ELIMINAR DE IDENTIFICADOR
    {
        printf("Comando ELIMINAR de tabla '%s'\n", $3);
    }
  |
      ELIMINAR DE IDENTIFICADOR DONDE condicion
    {
        printf("Comando ELIMINAR con condición en tabla '%s'\n", $3);
    }
    ;

/* ------ Condiciones con AND/OR ------ */
condicion:
      IDENTIFICADOR operador valor         { /* acción vacía */ }
    | condicion Y condicion                 { /* acción vacía */ }
    | condicion O condicion                 { /* acción vacía */ }
    ;

/* Operadores básicos (=, >, <) */
operador:
      IGUAL
    | MAYOR
    | MENOR
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
    printf("Ingrese una instrucción SQL en español (CTRL+D para salir):\n");
    yyparse();
    return 0;
}

