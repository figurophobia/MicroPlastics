#!/bin/bash

# Definir la ruta del archivo de origen en el directorio home
passwd_copia="$HOME/passwd_copia"

# Verifica que el archivo "passwd_copia" existe
if [ ! -f "$passwd_copia" ]; then
    echo "El archivo '$passwd_copia' no existe."
    exit 1
fi

# Contar líneas originales
original_lines=$(wc -l < "$passwd_copia")

# Ordenar, eliminar duplicados y guardar en /tmp/passwd original
sort -u "$passwd_copia" > /tmp/passwd_original

# Contar líneas después de procesar
filtered_lines=$(wc -l < /tmp/passwd_original)

# Calcular el número de líneas eliminadas
lines_removed=$((original_lines - filtered_lines))

echo "Número de líneas eliminadas: $lines_removed"

# Comparar con /etc/passwd
if diff -q /tmp/passwd_original <(sort /etc/passwd); then
    echo "El archivo /tmp/passwd original es igual a /etc/passwd."
else
    echo "El archivo /tmp/passwd original es diferente de /etc/passwd."
fi
