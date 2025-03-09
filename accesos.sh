#!/bin/bash


# Comprobamos que se pasen exactamente dos parámetros
if [ $# -ne 2 ]; then
   echo "Error: Debes pasar exactamente dos parámetros."
   echo "Uso: $0 [-c | GET | POST | -s | -o | -t] ruta/al/archivo/de/log/access.log"
   exit 1
fi


# Asignamos los parámetros a variables
OPCION=$1
ARCHIVO=$2


# Comprobamos que el archivo de log existe y tiene permisos de lectura
if [ ! -f "$ARCHIVO" ]; then
   echo "Error: El archivo $ARCHIVO no es válido o no tiene permisos de lectura."
   exit 1
fi


# Función para mostrar los códigos de respuesta
mostrar_codigos_respuesta() {
   awk '{print $9}' "$ARCHIVO" | sort | uniq -c
}


# Función para contar los días sin acceso
contar_dias_sin_acceso() {
   # Obtener las fechas de inicio y fin (formato: dd/MMM/yyyy)
   fecha_inicio=$(head -n 1 "$ARCHIVO" | awk '{print $4}' | sed 's/\[//;s/:.*//') 
   #Usamos sed para eliminar los corchetes y todo lo que haya detrás de los dos puntos, quedando solo la fecha en formato dd/MMM/yyyy
   fecha_fin=$(tail -n 1 "$ARCHIVO" | awk '{print $4}' | sed 's/\[//;s/:.*//')

   # Convertir las fechas al formato AAAA-MM-DD usando date
   fecha_inicio_format=$(date -d "$(echo $fecha_inicio | sed 's/\// /g')" +%Y-%m-%d)
   #Convierte la fecha con el mes escrito en letras a formato numérico
   fecha_fin_format=$(date -d "$(echo $fecha_fin | sed 's/\// /g')" +%Y-%m-%d)

   dias_sin_acceso=0
   
    fecha_actual=$fecha_inicio_format
   # Generar el rango de fechas entre la fecha de inicio y la fecha de fin
    while [ $(date -d "$fecha_actual" +%s) -lt $(date -d "$fecha_fin_format" +%s) ]; do
        # Comprobar si la fecha actual está presente en el archivo
        
        #Ponemos la fecha actual a formato DD/MES/YEAR para que coincida con el formato del archivo ESTILO 19/Dec/2023
        fecha_actual_format=$(LC_TIME=en_US.UTF-8 date -d "$fecha_actual" +%d/%b/%Y)
        
        if ! grep -iq "$fecha_actual_format" "$ARCHIVO"; then
            # Si no está presente, incrementamos el contador de días sin acceso
            echo "No hay acceso en la fecha: $fecha_actual_format"
            dias_sin_acceso=$((dias_sin_acceso + 1))
        fi

        # Incrementar la fecha un día
        fecha_actual=$(date -d "$fecha_actual + 1 day" +%Y-%m-%d)
    done

   echo "Días sin acceso: $dias_sin_acceso"
}

# Función para contar accesos GET o POST con respuesta 200
contar_get_post_200() {
   # Captura la fecha y hora actual en formato: Feb 12 11:10:31
   fecha_hora=$(date +"%b %d %H:%M:%S")


   # Verificamos si la opción es GET o POST
   if [[ "$OPCION" == "GET" ]]; then
       # Contamos accesos GET con respuesta 200, comprobamos que el campo 6 sea "GET (si, con la comilla) y el campo 9 sea 200
        total_accesos=$(awk '$6 ~ /GET/ && $9 == 200' "$ARCHIVO" | wc -l) # /GET/ es una expresión regular que busca GET en el campo 6
         tipo="GET"
    elif [[ "$OPCION" == "POST" ]]; then
       # Contamos accesos POST con respuesta 200
       total_accesos=$(awk '$6 ~ /POST/ && $9 == 200' "$ARCHIVO" | wc -l)
       tipo="POST"
   else
       echo "Error: Debes especificar 'GET' o 'POST'."
       exit 1
   fi


   # Muestra el resultado con el formato solicitado
   echo "$fecha_hora. Registrados $total_accesos accesos tipo $tipo con respuesta 200."
}


# Función para resumir los datos enviados por mes
resumen_datos_enviados() {
    # Usamos awk para procesar el archivo de log y calcular el total de bytes enviados por mes
    awk '{
        # Extraemos el mes (posiciones 4-6 del campo de fecha [dd/mes/yyyy])
        mes = substr($4, 5, 3)  # Tomamos los tres caracteres del mes (por ejemplo, "Dec", "Jan")
        
        # El campo 10 contiene los datos enviados en bytes
        bytes = $10
        
        # Acumulamos los bytes por mes
        suma[mes] += bytes
        count[mes] += 1  # Contamos las ocurrencias por mes
    }
    END {
        # Imprimimos los resultados por mes
        for (mes in suma) {
            # Convertir los bytes a KiB (dividiendo entre 1024)
            kiB = suma[mes] / 1024
            # Mostrar el resultado con el formato solicitado
            printf "%.0f KiB sent in %s by %d accesses.\n", kiB, mes, count[mes]
        }
    }' "$ARCHIVO"
}




# Función para ordenar el log por bytes enviados
ordenar_log() {
   sort -k 10 -n "$ARCHIVO" > access_ord.log # Ordena con -k 10 por el campo 10 (bytes enviados) y -n para ordenar numéricamente
}


# Dependiendo de la opción elegida, ejecutamos la función correspondiente
case $OPCION in
   -c)
       mostrar_codigos_respuesta
       ;;
   -t)
       contar_dias_sin_acceso
       ;;
   GET)
       contar_get_post_200
       ;;
   POST)
       contar_get_post_200
       ;;
   -s)
       resumen_datos_enviados
       ;;
   -o)
       ordenar_log
       ;;
   *)
       echo "Opción inválida. Uso: $0 [-c | GET | POST | -s | -o] ruta/al/archivo/de/log/access.log"
       exit 1
       ;;
esac


