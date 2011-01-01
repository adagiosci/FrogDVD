#!/bin/bash
# Primer script para automatizar la lectura de archivos
# que se usarán en las escenas del proyecto.
# Proyecto Frog DVD.
# Josué Ballinas Barrios joshyro@gmail.com
# Irving Sulub Chan irving_sci@hotmail.com
# Jose Enrique Alvarez Estrada leonardo_da_vinci_mx@hotmail.com
# Gracias al grupo IRC #tovid.
#Variables
BG_IMAGE=""
BG_IMAGE_HIGH=""
BG_IMAGE_SEL=""
BG_AUDIO=""
FORMAT=""
SPU_FILE=""
#termina variables
USAGE=`cat << EOF
Usage: frog [OPTION]

Common options:
      
    -background IMAGE                   ex: -background my_background.jpeg
    -high IMAGE                   	ex: -high my_background_highlight.png
    -sel IMAGE                  	ex: -sel my_background_Selected.png
    -audio AUDIOFILE                    ex: -audio silent.mp2
    -format             		ex: -format NTSC | PAL
    -xml				ex: -xml my_file.xml
Example:

    frog -background ocean.jpg -high first_Highligth.png -sel first_Selected.png -audio foo.mp2 -format ntsc -xml foo.mxl
    
EOF`
# Print script name, usage notes, and optional error message, then exit.
# Args: $@ == text string containing error message
usage_error ()
{
    printf "%s\n" "$USAGE"
    printf "%s\n" "$SEPARATOR"
    printf "*** %s\n" "$@"
    exit 1
}
#INICIA
if test $# -le 0; then
   usage_error "por favor ingrese al menos una variable"
    exit 1
fi

while test $# -gt 0; do
    case "$1" in
        "-background" )
            shift
            # Make sure file exists
            if test -f "$1"; then
                BG_IMAGE=$1
            else
                usage_error "Can't find background image file: $1"
            fi
            ;;
	"-high" )
            shift
            # Make sure file exists
            if test -f "$1"; then
                BG_IMAGE_HIGH=$1
            else
                usage_error "Can't find highlight image file: $1"
            fi
            ;;
	"-sel" )
            shift
            # Make sure file exists
            if test -f "$1"; then
                BG_IMAGE_SEL=$1
            else
                usage_error "Can't find selected image file: $1"
            fi
            ;;
	 "-audio" )
            shift
            # Make sure file exists
            if test -f "$1"; then
                BG_AUDIO=$1
            else
                usage_error "Can't find background audio file: $1"
            fi
            ;;
	"-format" )
            shift
      	    FORMAT="$1"
            ;;
         "-xml" )
            shift
            # Make sure file exists
            if test -f "$1"; then
                SPU_FILE=$1
            else
                usage_error "Can't find background audio file: $1"
            fi
	    ;;
         "*")
            test -n "$1" && usage_error "Unrecognized command-line option: $1"
            ;;
	
    esac

    # Get the next argument
    shift
done


#Pasamos los parametros a su respectivo.

#BG_IMAGE="$1"
#BG_VIDEO="$2"
#BG_SEL="$2"
#BG_HIGH="$3"
#AUDIO="$4"
#FORMAT="$5" #Selecccionar el tipo de video, para PAL o NTSC, sustituir el valor.
#SPU_FILE="$6"
LOG_FILE="frog.log"
sleep 1s
echo """"""""""""""""""""""""""""""""""""""""""
echo "Los archivos comenzarán a ser procesados"
echo """"""""""""""""""""""""""""""""""""""""""
sleep 1s

    FINAL_NAME=$(echo $BG_IMAGE | cut -d "." -f1) #quitar la extensión del archivo. implementado en primera versión.
   
 rm $BG_IMAGE.mpg &> /dev/null
    #Verifica si los colores son los indicados para trabajar con los archivos de botones High & Selec
    if [ "$(identify -format '%k' $BG_IMAGE_HIGH)" -gt 4 ]; then
	echo -e "***************************************************************************************************************"  
	echo -e "*  $BG_IMAGE_HIGH no puede ser procesada, use un editor de imágenes para reducir los colores a 4 o menos   *"
	echo -e "***************************************************************************************************************"
        exit 1
        else
	sleep 1s
	echo "$BG_IMAGE_HIGH correcto"
	sleep 1s
    fi
    if [ "$(identify -format '%k' $BG_IMAGE_SEL)" -gt 4 ]; then
	echo -e "***************************************************************************************************************"  
	echo -e "*  $BG_IMAGE_SEL no puede ser procesada, use un editor de imágenes para reducir los colores a 4 o menos  *"
	echo -e "***************************************************************************************************************"
	exit 1
	else 
	sleep 1s
	echo "$BG_IMAGE_SEL correcto"
	sleep 1s
    fi 
	sleep 1s
	echo "$FORMAT"
	sleep 1s

      if [[ $FORMAT = "NTSC" || $FORMAT = "ntsc" ]]; then
	#empieza la conversión de archivos.
	convert $BG_IMAGE ppm:- | ppmtoy4m -n1 -F 30000:1001 -A10:11 -I p -r -S 420mpeg2 | yuvscaler -O SIZE_720x480 | mpeg2enc -a 2 -F 4 -n n -f8 -b5000 -a3 -o $BG_IMAGE.m2v
	mplex -f 8 -o /dev/stdout $BG_IMAGE.m2v $AUDIO | spumux -v 2 $SPU_FILE > $FINAL_NAME.mpg
	echo "Archivo $FINAL_NAME.mpg generado..."
      else 
	convert $BG_IMAGE ppm:- | ppmtoy4m -n 1 -F25:1 -I t -A 59:54 -L -S 420mpeg2 | mpeg2enc -f 8 -n p -o $BG_IMAGE.m2v
	mplex -f 8 -o /dev/stdout $BG_IMAGE.m2v $AUDIO | spumux -v 2 $SPU_FILE > $FINAL_NAME.mpg
	echo "Archivo $FINAL_NAME.mpg generado..."
      fi