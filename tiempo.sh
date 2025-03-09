#!/bin/bash

#Script 6

## Comprueba si como argumento se paso una fecha

#!/bin/bash

#$# danos o total de argumentos, despois -ne (non equal) comproba que o numero de argumentos sexa distinto de un
if [ $# -ne 1 ]; then
    echo "Uso: $0 YYYY-MM-DD" ##Entron mostro o formato de entrada do argumento
    exit 1
fi

#Gardo a fecha introducida polo usuario nunha variable
FECHA_INICIO=$1 # No $0 encontramos o nome do archivo, e no $1 e o primeiro argumento, enton collo o primeiro argumento (a fecha do usuario) e gardo na variable fecha inicio


TIEMPO_INICIO=$(date -d "$FECHA_INICIO" +%s 2>/dev/null) # Aqui o que fago e pasar a formato date o argumento de entrada, poño date -d para que me acepte un string e pasolle a miña variable. 
#Despois co +%s convirto a fecha a segundos, despois 2>/dev/null sirve para redireccionar os errores estandar a un ficheiro (2=stderr) e que non me salte ningun en caso de que se introduzca mal a fecha


# Verificar si a fecha é valida
if [ -z "$TIEMPO_INICIO" ]; then #Con -z verifico si a variable está vacía.(si non esta vacía significa a que se pasou correctamente a segundos, si esta vacía fallou o date)
    echo "Error: Formato de fecha inválido. Use YYYY-MM-DD."
    exit 1
fi



TIEMPO_ACTUAL=$(date +%s) ## aqui collemos a fecha actual en segundos, utilizo directamente date e pasoa a segundos
TOTAL_DIAS=$(( ( $(date +%s) - $(date -d "$FECHA_INICIO" +%s) ) / 86400 )) ## Calculo a diferencia en segundos e depois pasoa a dias (1 día= 24 h*60m*60s= 86400)




# Convertir la diferencia a anos dias e segundos
ANOS=$((TOTAL_DIAS / 365))  # 1 año = 365 dias
DIAS=$((TOTAL_DIAS % 365))
#Hai que ter en conta que co cambio do calendario juliano perderonse 10 días
TIEMPO_CAMBIOCALENDARIO=$(date -d "1582-10-15" +%s) #Fecha na quue se produxo o cambio de calendario, poñoa en segundos pa poder comparar

#Agora comporbo que si a fecha e anterior a do cambio, se resten os 10 dias que se perderon

if [ "$TIEMPO_INICIO" -lt "$TIEMPO_CAMBIOCALENDARIO" ]; then
    TOTAL_DIAS=$((TOTAL_DIAS - 10))
fi

#echo "$TOTAL_DIAS"

ANOS=$((TOTAL_DIAS / 365))  # 1 año = 365 dias
DIAS=$((TOTAL_DIAS % 365))

# Hai que ter en conta os anos bisiestos
for ((i=0; i<$ANOS ;i++)); do
    #ANO=$(($(date -d "$FECHA_INICIO $i años" +%Y)))
    if (((ANOS %4 == 0 && ANOS%100 !=0) || (ANOS% 400 ==0))); then 
        DIAS=$((DIAS -1))
        echo "$DIAS"
    fi
done

#echo "$DIAS"

## Hai que ter en conta os minutos transcurridos o dia actual
HORA_INICIO=$(date -d "$FECHA_INICIO" +%H)
MINUTOS=$(( 10#$(date +%M)+ 10#$(date +%H)*60 - HORA_INICIO*60)) # Ponemos 10# para que interprete os numeros como base 10 e non como base 8



#finalmente imprimo o resultado por pantalla
echo "Tiempo transcurrido desde $FECHA_INICIO:"
echo "$ANOS años, $DIAS días y $MINUTOS minutos"
