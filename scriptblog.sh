read -p "¿Has añadido archivos nuevos? (y/n) " nuevos
read -p "¿Cual va a ser el commit? " comentario

if [ $nuevos == "y" ]
    then
    git add .
    git commit -am "$comentario"
    git push
    hugo -d  ../alepeteporico.github.io/
    bash /home/alejandrogv/Escritorio/ASIR/IWEB/hugo/alepeteporico.github.io/script1.sh

elif [ $nuevos == "n": ]
    then
    git commit -am "$comentario"
    git push
    hugo -d  ../alepeteporico.github.io/
    bash /home/alejandrogv/Escritorio/ASIR/IWEB/hugo/alepeteporico.github.io/script2.sh

fi