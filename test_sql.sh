#!/bin/bash

INPUT_FILE="$1"
EXECUTABLE="./sql"

if [ -z "$INPUT_FILE" ]; then
  echo "Uso: $0 <archivo_de_pruebas>"
  exit 1
fi

if [ ! -f "$EXECUTABLE" ]; then
  echo "No se encontró el ejecutable $EXECUTABLE. Compílalo antes de ejecutar este script."
  exit 1
fi

LINE_NUM=0
while IFS= read -r line || [ -n "$line" ]; do
  LINE_NUM=$((LINE_NUM+1))
  # Saltar líneas vacías o comentarios
  if [[ -z "$line" || "$line" =~ ^-- || "$line" =~ ^// ]]; then
    continue
  fi
  echo "=============================="
  echo "Consulta #$LINE_NUM:"
  echo "$line"
  echo "------------------------------"
  # Ejecutar la consulta y capturar la salida
  output=$(echo "$line" | $EXECUTABLE)
  echo "$output"
  echo "=============================="
  echo
  sleep 0.1
done < "$INPUT_FILE"
