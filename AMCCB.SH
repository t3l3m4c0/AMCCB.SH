#!/bin/bash

# Función para mostrar el menú y seleccionar un directorio
function seleccionar_directorio {
    PS3="Seleccione el directorio a comprimir: "
    # Obtener una lista de directorios en el directorio actual
    directorios=(*/)
    directorios+=("Cancelar")

    select DIR in "${directorios[@]}"; do
        case $DIR in
            "Cancelar")
                echo "Operación cancelada."
                exit 1
                ;;
            *)
                if [ -n "$DIR" ]; then
                    DIR=${DIR%/}
                    break
                else
                    echo "Selección inválida. Intente de nuevo."
                fi
                ;;
        esac
    done
}

# Comprobar si se ha proporcionado un argumento
if [ $# -eq 0 ]; then
    seleccionar_directorio
else
    DIR=$1
fi

# Comprobar si el directorio existe
if [ ! -d "$DIR" ]; then
    echo "El directorio $DIR no existe."
    exit 1
fi

# Nombre del archivo comprimido
TARFILE="${DIR%/}.tar.gz"

# Crear un archivo tar.gz y mostrar el progreso con pv
tar cf - "$DIR" --remove-files | pv -s $(du -sb "$DIR" | awk '{print $1}') | gzip > "$TARFILE"

# Preguntar si se desea borrar la carpeta de origen
read -p "¿Deseas borrar la carpeta de origen $DIR (yes/no)? [yes]: " confirm
confirm=${confirm:-yes}

if [ "$confirm" == "yes" ]; then
    rm -rf "$DIR"
    echo "La carpeta $DIR ha sido borrada."
else
    echo "La carpeta $DIR no ha sido borrada."
fi
