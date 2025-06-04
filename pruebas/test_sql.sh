#!/bin/bash

INPUT_FILE="consultas-test.txt"
EXECUTABLE="./sql"

if [ ! -f "$EXECUTABLE" ]; then
  echo "No se encontró el ejecutable $EXECUTABLE. Compílalo antes de ejecutar este script."
  exit 1
fi

LINE_NUM=0
while IFS= read -r line || [ -n "$line" ]; do
  LINE_NUM=$((LINE_NUM+1))
  # Saltar líneas vacías o comentarios
  if [[ -z "$line" || "$line" =~ ^// ]]; then
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
  # Opcional: Pausa para leer cada resultado
  # read -n 1 -s -r -p "Presiona cualquier tecla para continuar..."
done < "$INPUT_FILE"

