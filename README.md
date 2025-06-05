# Analizador Sintáctico SQL en Español

## Descripción del Software

Este proyecto implementa un analizador sintáctico para un subconjunto del lenguaje SQL, con la particularidad de que las palabras clave y la estructura de los comandos están en español. El software es capaz de procesar sentencias DML (Data Manipulation Language) como `INSERTAR`, `SELECCIONAR`, `ACTUALIZAR` y `ELIMINAR`. Las sentencias procesadas y validadas sintácticamente se escriben en un archivo de salida llamado `queries-result.txt`.

El analizador está construido utilizando herramientas clásicas de compiladores: Flex para el análisis léxico y Bison para el análisis sintáctico, con acciones semánticas escritas en C.

## Componentes y Tecnologías

*   **Lenguaje de implementación**: C (para las acciones semánticas y funciones auxiliares).
*   **Analizador Léxico**: Flex (o una herramienta compatible como Lex).
*   **Analizador Sintáctico**: Bison (o una herramienta compatible como YACC).
*   **Sistema Operativo**: Desarrollado y probado principalmente en entornos tipo UNIX (Linux, macOS). Para Windows, se requiere un entorno compatible como MinGW, Cygwin o WSL (Windows Subsystem for Linux).
*   **Compilador C**: GCC (GNU Compiler Collection) o compatible.

## Estructura del Proyecto

```
.
├── pruebas/
│   ├── consultas-delete-test.txt
│   ├── consultas-insert-test.txt
│   ├── consultas-select-test.txt
│   ├── consultas-update-test.txt
│   └── test_sql.sh     // (Este es un script de prueba para validar las respuestas del analizador)
├── queries-result.txt
├── run.sh
├── sql                 // (Este es el ejecutable generado)
├── sql.l
├── sql.y
└── README.md 
```

**Descripción de Archivos y Directorios Clave:**

*   `sql.y`: Archivo de entrada para Bison. Contiene la definición de la gramática del lenguaje SQL en español, las reglas de precedencia de operadores y las acciones semánticas en C que se ejecutan al reconocer cada regla. Estas acciones incluyen la generación de la salida en `queries-result.txt`.
*   `sql.l`: Archivo de entrada para Flex. Define los patrones (expresiones regulares) para reconocer los componentes léxicos (tokens) del lenguaje, como palabras clave (`insertar`, `seleccionar`), identificadores, cadenas, números, etc.
*   `run.sh`: Script de shell para automatizar el proceso de compilación (usando Flex y Bison para generar los archivos `.c`, y luego GCC para compilarlos en un ejecutable) y la ejecución del analizador.
*   `queries-result.txt`: Archivo de texto donde el analizador escribe las sentencias SQL procesadas y formateadas. Se crea o se añade contenido a este archivo cada vez que se procesa una sentencia válida.
*   `pruebas/`: Directorio que contiene archivos de texto (`.txt`) con ejemplos de sentencias SQL en español para probar las diferentes operaciones (`insertar`, `seleccionar`, `actualizar`, `eliminar`).
    *   `consultas-delete-test.txt`: Pruebas específicas para sentencias `eliminar`.
    *   `consultas-insert-test.txt`: Pruebas específicas para sentencias `insertar`.
    *   `consultas-select-test.txt`: Pruebas específicas para sentencias `seleccionar`.
    *   `consultas-update-test.txt`: Pruebas específicas para sentencias `actualizar`.
    *   `test_sql.sh`: (Dentro de `pruebas/`) Script de shell, utilizado para ejecutar las pruebas contenidas en los archivos `.txt` contra el analizador.
*   `sql`: Nombre común para el archivo ejecutable generado tras la compilación.

## Comandos Soportados

El analizador soporta las siguientes sentencias SQL en español:

1.  **INSERTAR**:
    *   `insertar en <tabla> valores (<lista_valores>);`
    *   `insertar en <tabla> (<lista_campos>) valores (<lista_valores>);`

2.  **SELECCIONAR**:
    *   `seleccionar <campos> de <tabla>;`
    *   `seleccionar <campos> de <tabla> donde <condicion>;`
    *   `<campos>` puede ser `todos` (equivalente a `*`) o una lista de identificadores separados por comas.

3.  **ACTUALIZAR**:
    *   `actualizar <tabla> establecer <campo> a <valor>;`
    *   `actualizar <tabla> establecer <campo> a <valor> donde <condicion>;`

4.  **ELIMINAR**:
    *   `eliminar de <tabla>;`
    *   `eliminar de <tabla> donde <condicion>;`

**Condiciones**:
Las condiciones en las cláusulas `donde` pueden ser simples (`<identificador> <operador> <valor>`) o compuestas mediante los operadores lógicos `y` (AND) y `o` (OR).
*   Operadores de comparación soportados: `igual`, `mayor`, `menor`, `mayor igual`, `menor igual`, `no igual`.

## Instalación y Compilación

**Prerrequisitos:**

*   **Flex**: Instalador del generador de analizadores léxicos.
    *   En Debian/Ubuntu: `sudo apt-get install flex`
    *   En Fedora: `sudo dnf install flex`
    *   En macOS (con Homebrew): `brew install flex`
*   **Bison**: Instalador del generador de analizadores sintácticos.
    *   En Debian/Ubuntu: `sudo apt-get install bison`
    *   En Fedora: `sudo dnf install bison`
    *   En macOS (con Homebrew): `brew install bison`
*   **GCC (o un compilador C compatible)**:
    *   En Debian/Ubuntu: `sudo apt-get install build-essential`
    *   En Fedora: `sudo dnf groupinstall "Development Tools"`
    *   En macOS: Xcode Command Line Tools (instalar con `xcode-select --install`)

**Pasos de Compilación (manual):**

1.  **Generar el analizador léxico (desde `sql.l`):**
    ```bash
    flex sql.l
    ```
    Esto generará el archivo `lex.yy.c`.

2.  **Generar el analizador sintáctico (desde `sql.y`):**
    ```bash
    bison -d sql.y
    ```
    Esto generará los archivos `sql.tab.c` (el código del parser) y `sql.tab.h` (las definiciones de los tokens, para ser usadas por `lex.yy.c`). La opción `-d` es importante para crear el archivo `.h`.

3.  **Compilar los archivos C generados y enlazarlos:**
    ```bash
    gcc sql.tab.c lex.yy.c -o sql_parser -lfl 
    ```
    *   `-o sql_parser`: Especifica el nombre del archivo ejecutable de salida (puedes llamarlo `sql` o como prefieras).
    *   `-lfl`: En algunos sistemas, es necesario enlazar la librería de Flex. Si da error, prueba sin ella o con `-ly` para YACC si es necesario (aunque usualmente no lo es para Bison).

**Compilación usando el script `run.sh` (Recomendado):**

El script `run.sh` automatiza estos pasos. Para usarlo:
1.  Asegúrate de que el script tiene permisos de ejecución:
    ```bash
    chmod +x run.sh
    ```
2.  Ejecuta el script:
    ```bash
    ./run.sh
    ```

## Ejecución del Analizador

Una vez compilado (generando el ejecutable `sql`), puedes ejecutar el analizador de las siguientes maneras:

*   **Modo Interactivo**:
    Puedes ejecutar el analizador y escribir las sentencias SQL en español directamente en la terminal. Presiona `Ctrl+D` para finalizar la entrada.
    ```bash
    ./sql
    ```
    Luego, ingresa tus consultas, por ejemplo:
    `seleccionar todos de clientes donde id = 10;`
    (Presiona Enter después de cada sentencia terminada en `;`)

*   **Desde un Archivo de Entrada**:
    Puedes redirigir el contenido de un archivo con sentencias SQL al analizador:
    ```bash
    ./sql < archivo_de_consultas.txt
    ```
    Por ejemplo, para usar uno de los archivos de prueba:
    ```bash
    ./sql < pruebas/consultas-select-test.txt
    ```

**Salida:**
Las sentencias SQL que sean sintácticamente correctas según la gramática definida en `sql.y` serán procesadas, y la representación correspondiente (según se define en las acciones semánticas) se añadirá al archivo `queries-result.txt`. Si hay errores sintácticos, se mostrará un mensaje de error en la salida estándar de error (stderr).

## Ejecución de Pruebas

El proyecto incluye scripts y archivos para pruebas:

*   **Archivos de prueba**: Ubicados en el directorio `pruebas/`, contienen colecciones de sentencias para cada tipo de operación (`consultas-insert-test.txt`, `consultas-select-test.txt`, etc.).
*   **Script de prueba `pruebas/test_sql.sh`**: Este script ejecuta el analizador contra los archivos de prueba en su directorio. Para ejecutarlo:
    1.  Navega al directorio de pruebas: `cd pruebas`
    2.  Asegúrate de que tiene permisos de ejecución: `chmod +x test_sql.sh`
    3.  Ejecútalo: `./test_sql.sh`
*   **Script de prueba `test_sql.sh` (raíz)**: Similar al anterior, pero ejecutado desde el directorio raíz del proyecto.

Es recomendable revisar el contenido de estos scripts para entender cómo funcionan y qué esperan como resultado (por ejemplo, si comparan la salida con un resultado esperado).

## Consideraciones del Sistema Operativo

*   **Linux/macOS**: El proyecto está orientado a estos sistemas, especialmente por el uso de scripts de shell (`.sh`). Flex, Bison y GCC son herramientas estándar en estos entornos.
*   **Windows**:
    *   **WSL (Windows Subsystem for Linux)**: Es la forma más sencilla de tener un entorno Linux completo en Windows, donde las herramientas y scripts funcionarán de forma nativa.
    *   **MinGW/MSYS2**: Proporciona un entorno de desarrollo GNU en Windows, permitiendo usar Flex, Bison y GCC. Podría ser necesario ajustar los scripts o comandos ligeramente.
    *   **Cygwin**: Otra alternativa para tener un entorno similar a UNIX en Windows.

---

<div align="center">
  Hecho con ❤️ por Ssnati y Karen
</div>
