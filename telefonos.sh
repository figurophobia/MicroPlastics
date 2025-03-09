#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Debes pasar un archivo de texto"
    exit 1
fi

AXENDA=$1

# Función que crea unha axenda nova
# Función que crea unha axenda nova
crear_axenda(){
    if [ -f "$AXENDA" ]; then
        # El archivo ya existe, preguntamos al usuario si desea sobrescribirlo
        echo "O arquivo '$AXENDA' xa existe. Queres sobrescribirlo? (s/n)"
        read respuesta
        if [ "$respuesta" = "s" ] || [ "$respuesta" = "S" ]; then
            > "$AXENDA"  # Esto vaciará o archivo
            echo "Axenda sobrescrita correctamente"
        else
            echo "Non se realizou ningún cambio."
        fi
    else
        # Si el archivo no existe, creamos uno nuevo
        touch "$AXENDA"
        echo "Axenda creada correctamente"
    fi
}
# Función que permite buscar por nome
buscar_nome(){
    echo "Introduce a persoa que deseas buscar:"
    read nome
    resultado=$(grep -i "$nome@" "$AXENDA")
    if [ -z "$resultado" ]; then
        echo "Non se atopou a persoa"
    else
        echo "$resultado"
    fi
}

# Función que permite buscar por teléfono
buscar_telefono(){
    echo "Introduce o número de teléfono:"
    read telefono
    resultado=$(grep -i "$telefono" "$AXENDA")
    if [ -z "$resultado" ]; then
        echo "Non se atopou ese número"
    else
        echo "$resultado"
    fi
}

# Función que permite rexistrar unha nova entrada, revisará si o nome ou o telefono xa están e avisará
nova_entrada(){
    echo "Introduce o nome:"
    read nome
    echo "Introduce o teléfono:"
    read telefono

    # Verificar se o nome ou o teléfono xa existen na axenda
    if grep -iq "^$nome@" "$AXENDA"; then
        echo "Erro: O nome '$nome' xa está rexistrado na axenda."
        return
    fi

    if grep -iq "@$telefono$" "$AXENDA"; then
        echo "Erro: O teléfono '$telefono' xa está rexistrado na axenda."
        return
    fi

    # Gardar a nova entrada na axenda
    echo "$nome@$telefono" >> "$AXENDA"
    echo "A entrada gardouse correctamente."
}

# Función para modificar unha entrada, preguntará si queremos modificar o nome ou o telefono
modificar_entrada(){
    if [ -e "$AXENDA" ]; then
        echo "Dime o nome ou teléfono da entrada que queres modificar:"
        read input

        # Buscar a entrada por nome ou teléfono
        if grep -iq "^$input@" "$AXENDA"; then
            # Se se atopa por nome
            linea=$(grep -n -i "^$input@" "$AXENDA" | cut -d: -f1)
            nome_antigo=$(sed -n "${linea}p" "$AXENDA" | cut -d@ -f1)
            telefono_antigo=$(sed -n "${linea}p" "$AXENDA" | cut -d@ -f2)

            echo "Que queres modificar?"
            echo "1) Modificar o nome"
            echo "2) Modificar o teléfono"
            read opcion

            case $opcion in
                1)
                    echo "Introduce o novo nome:"
                    read novo_nome
                    # Modificar o nome na axenda
                    sed -i "${linea}s/^$nome_antigo@/$novo_nome@/" "$AXENDA"
                    echo "Nome modificado correctamente."
                    ;;
                2)
                    echo "Introduce o novo número de teléfono:"
                    read novo_telefono
                    # Modificar o número de teléfono na axenda
                    sed -i "${linea}s/@$telefono_antigo$/@$novo_telefono/" "$AXENDA"
                    echo "Número de teléfono modificado correctamente."
                    ;;
                *)
                    echo "Opción non válida."
                    ;;
            esac
        else
            echo "Non se atopou ningunha entrada para '$input'."
        fi
    else
        echo "Non existe a axenda, crea unha."
    fi
}

# Función para borrar unha entrada
borrar_entrada(){
    if [ -e "$AXENDA" ]; then #Comprobamos se existe a axenda -e é para comprobar se existe
        echo "Dime o nome que queres borrar:"
        read nome
        linea=$(grep -n -i "$nome@" "$AXENDA" | cut -d: -f1)

        if [ -z "$linea" ]; then
            echo "Non se atopou ese nome"
        else 
            sed -i "${linea}d" "$AXENDA"
            echo "Entrada eliminada"
        fi
    else
        echo "Non existe a axenda, crea unha."
    fi
}

# Menú de opcións
while true; do
    echo ""
    echo "Elixe unha opción:"
    echo "1) Crear unha nova axenda"
    echo "2) Buscar por nome"
    echo "3) Buscar por número"
    echo "4) Modificar unha entrada"
    echo "5) Crear unha nova entrada"
    echo "6) Borrar unha entrada"
    echo "7) Saír"
    echo ""

    read -r opcion

    case $opcion in
        1) crear_axenda ;;
        2) buscar_nome ;;
        3) buscar_telefono ;;
        4) modificar_entrada ;;
        5) nova_entrada ;;
        6) borrar_entrada ;;
        7) echo "Saíndo..."; exit 0 ;;
        *) echo "Opción non válida" ;;
    esac
done
