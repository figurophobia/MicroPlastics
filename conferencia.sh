#!/bin/bash

# Verificar que se pasaron exactamente dos argumentos (origen y destino)
if [ $# -ne 2 ]; then
    echo "Uso: $0 <directorio_origen> <directorio_destino>"
    exit 1
fi

# Asignar parámetros a variables
origen="$1"
destino="$2"

# Verificar que el directorio origen existe y tiene permisos de lectura
if [ ! -d "$origen" ] || [ ! -r "$origen" ]; then
    echo "Error: El directorio de origen '$origen' no existe o no tiene permisos de lectura."
    exit 1
fi

# Verificar que el directorio destino existe y tiene permisos de escritura
if [ ! -d "$destino" ] || [ ! -w "$destino" ]; then
    echo "Error: El directorio de destino '$destino' no existe o no tiene permisos de escritura." 
    exit 1
fi

# Verificar si el destino ya tiene subdirectorios tipo "salaXX"
if ls "$destino" | grep -qE '^sala[0-9]+$'; then
    # Con el -q, grep no imprime nada, solo devuelve 0 si encuentra algo
    # E para que interprete el regex
    # ^ sirve para que empiece por sala y [0-9]+ para que tenga uno o más dígitos
    # $ fin de la línea
    # Se usa comillas simples para que se mantenga el regex sin ser interpretado por la shell
    echo "Error: El directorio destino ya contiene subdirectorios de salas."
    exit 1
fi

# Crear directorios de salas (20 a 50) en el destino
for sala in $(seq 20 50); do
    mkdir -p "$destino/sala$sala"
done

# Procesar cada archivo en el directorio de origen
for archivo in "$origen"/*; do
    # Verificar que sea un archivo y que cumpla el formato sala_XX_fecha@hora.res
    if [[ ! -f "$archivo" ]]; then #Si no es archivo, salta al siguiente
        continue
    fi
    
    # Extraer información del nombre del archivo
    nombre_archivo=$(basename "$archivo") #Extraemos o nome do arquivo

    #Formato sala_XX_YYYY-MM-DD@HH:MM.res

    if [[ "$nombre_archivo" =~ sala_([0-9]+)_([0-9]{4}-[0-9]{2}-[0-9]{2})@([0-9]{2}:[0-9]{2})\.(HD|Full HD|4K|8K) ]]; then
    
        sala="${BASH_REMATCH[1]}" # Almacena o valor de XX (primer parentesis)
        fecha="${BASH_REMATCH[2]}" #Almacena o valor de YYYY-MM-DD (segundo parentesis)
        hora="${BASH_REMATCH[3]}" #Almacena o valor de HH:MM (tercer parentesis)
        resolucion="${BASH_REMATCH[4]}" #Almacena o valor de la resolución (cuarto parentesis)
       
        # Validar que la sala esté en el rango permitido
        if (( sala < 20 || sala > 50 )); then
            echo "Advertencia: Sala $sala fuera de rango, archivo ignorado ($nombre_archivo)."
            continue
        fi
        
        # Crear subdirectorios si no existen
        mkdir -p "$destino/sala$sala/$fecha/$resolucion"
        
        # Copiar el archivo con el nuevo nombre
        cp "$archivo" "$destino/sala$sala/$fecha/$resolucion/charla_$hora"
        
        echo "Copiado: $archivo -> $destino/sala$sala/$fecha/$resolucion/charla_$hora"
    else
        echo "Advertencia: Formato inválido, archivo ignorado ($nombre_archivo)."
    fi
done

echo "Proceso completado."
