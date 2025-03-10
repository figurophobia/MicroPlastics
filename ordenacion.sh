#!/bin/bash

# Verificar que se haya proporcionado un directorio
if [ $# -ne 2 ]; then
    echo "Uso: $0 <opcion> <directorio>"
    echo "Opciones:"
    echo "  -a : Ordenar por número de caracteres en los nombres de los archivos."
    echo "  -b : Ordenar por orden alfabético de los nombres escritos al revés."
    echo "  -c : Ordenar por los últimos 4 dígitos del inode, de menor a mayor."
    echo "  -d : Ordenar por tamaño y organizados en grupos según permisos rwx del propietario."
    echo "  -e : Ordenar por tamaño y organizados en grupos según el mes de último acceso."
    exit 1
fi

DIRECTORIO="$2"
OPCION="$1"

# Verificar que el directorio existe
if [ ! -d "$DIRECTORIO" ]; then
    echo "Error: El directorio '$DIRECTORIO' no existe."
    exit 1
fi

case "$OPCION" in
    -a)
        echo "Ordenando por número de caracteres en los nombres:"
        ls -1 "$DIRECTORIO" | awk '{print length, $0}' | sort -n
        # -1 para que ls muestre un archivo por línea
        # awk '{print length, $0}' para imprimir la longitud de cada línea seguida del nombre del archivo
        # sort -n para ordenar numéricamente
        ;;
    -b)
        echo "Ordenando por orden alfabético de los nombres escritos al revés:"
        ls -1 "$DIRECTORIO" | rev | sort | rev # -1 para que ls muestre un archivo por línea
        # rev invierte el orden de los caracteres de cada línea
        # sort ordena las líneas alfabéticamente
        # rev vuelve a invertir el orden de los caracteres de cada línea
        ;;
    -c)
        echo "Ordenando por los últimos 4 dígitos del inode:"
        ls -i "$DIRECTORIO" | awk '{print substr($1, length($1)-3), $2}' | sort -n
        #-i para que ls muestre el número de inode
        #substr($1, length($1)-3) para obtener los últimos 4 dígitos del inode
        #sort -n para ordenar numéricamente
        ;;
    -d)
        echo "Ordenando por tamaño y agrupados según permisos rwx del propietario:"
        ls -l "$DIRECTORIO" | awk '{print substr($1,2,3), $5, $9}' | sort -k1,1 -k2,2n
        # -l para que ls muestre información detallada
        # substr($1,2,3) para imprimir solamente los permisos del propietario, los 3 primeros caracteres de la primera columna
        # (sin el primer carácter que indica el tipo de archivo)
        # $5 para imprimir el tamaño del archivo
        # $9 para imprimir el nombre del archivo
        # sort -k1,1 para ordenar primero por el primer campo (permisos) 
        # y -k2,2n para ordenar después por el segundo campo (tamaño) de forma numérica, si tienen el mismo valor en el primer campo
        ;;
    -e)
        echo "Ordenando por tamaño y agrupados según el mes de último acceso:"
        ls -lu "$DIRECTORIO" | awk '{print $6, $5, $9}' | sort -k1,1 -k2,2n
        # -lu para que ls muestre información detallada y use la fecha de último acceso
        # $6 para imprimir el mes de último acceso
        # $5 para imprimir el tamaño del archivo
        # $9 para imprimir el nombre del archivo
        # sort -k1,1 para ordenar primero por el primer campo (mes)
        # y -k2,2n para ordenar después por el segundo campo (tamaño) de forma numérica, si tienen el mismo valor en el primer campo

        ;;
    *)
        echo "Opción no válida. Usa -a, -b, -c, -d o -e."
        exit 1
        ;;
esac
