+++
title = "Implantanción y despliegue de una web estática"
description = "En está practica usaremos Hugo para generar la página web estática y Github Pages para desplegarla"
tags = [
    "IWEB"
]
date = "2021-02-15"
menu = "main"
+++


**La instalación es tan sencilla como usar apt:**

    sudo apt install hugo

**Una vez instalado el siguiente paso sería crear un sitio web:**

    hugo new site [nombre]

**Esto creará una carpeta donde podremos configurar nuestra página, para ello primero descargaremos desde [la página oficial de hugo](https://themes.gohugo.io/) un tema. Debemos fijarnos que se corresponde con nuestra versión de hugo o es inferior, si elegimos una plantilla que necesite una versión de hugo superior dará problemas.**


**Una vez escogida nuestra plantilla clonaremos el respositorio en la carpeta themes, dentro que se encuentra dentro de la carpeta de configuración de nuestra página:**

    git clone git@github.com:LordMathis/hugo-theme-nix.git

**Dentro del respositorio tendremos que copiar el contenido la carpeta exampleSites al raiz:**

    cp -r exampleSite/* ../../

**Una vez hayamos hecho esto simplemente ejecutaremos debemos ejecutar nuestro servidor en local y entraremos en localhost por el puerto 1313**


    alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/hugo/alepeteporicoblog$ hugo server

                       | EN  
    +------------------+----+
      Pages            | 40  
      Paginator pages  |  2  
      Non-page files   |  1  
      Static files     | 17  
      Processed images |  0  
      Aliases          |  9  
      Sitemaps         |  1  
      Cleaned          |  0  

    Total in 66 ms
    Watching for changes in /home/alejandrogv/Escritorio/ASIR/IWEB/hugo/alepeteporicoblog/{content,data,layouts,static,themes}
    Watching for config changes in /home/alejandrogv/Escritorio/ASIR/IWEB/hugo/alepeteporicoblog/config.toml
    Environment: "development"
    Serving pages from memory
    Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
    Web Server is available at //localhost:1313/ (bind address 127.0.0.1)
    Press Ctrl+C to stop

**Lo unico que faltaría sería modificar la web a nuestro gusto, el archivo de configuración general suele ser config.toml que está en el directorio raiz. Y el contenido de la página está en la carpeta content**

**Una vez que la página está a nuestro gusto podremos empezar a implementarla en github pages, crearemos un respositorio vacío en github, al que llamaré alepeteporico.github.io clonaremos el repositorio y crearemos el contenido estático en este repositorio con el siguiete comando**

    alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/hugo/blog_hugo$ hugo -d ../alepeteporicoblog.github.io/


**Ahora deberemos entrar en la configuración de nuestro repostirorio para añadir nuestra página a GithubPages, en la option podremos encontrar el apartado GithubPages**

![apartado_Githubpages](/implantacion_web_estatica/2.png)

**Cambiaremos el Source de none a main y entonces se generará la URL de nuestra página**

![none](/implantacion_web_estatica/3.png)

**Y ya tendremos nuestra [página](https://alepeteporico.github.io/) desplegada, solo tendremos que ir añadiendo contenido**

![pagina](/implantacion_web_estatica/4.png)

**También he creado un script que al ejecutarlo añade los cambios directamente a los dos repositorios y realiza el hugo -d para actualizar la página estática, este lo situariamos en la carpeta donde se encuentran los dos repositorios y el codigo sería el siguiente:**

    read -p "¿Has añadido archivos nuevos? (y/n) " nuevos
    read -p "¿Cual va a ser el commit? " comentario

    if [ $nuevos == "y" ]
        then
        cd blog_hugo/
        git add .
        git commit -am "$comentario"
        git push
        hugo -d  ../alepeteporico.github.io/
        cd ../alepeteporico.github.io/
        git add .
        git commit -am "$comentario"
        git push

    elif [ $nuevos == "n" ]
        then
        cd blog_hugo/
        git commit -am "$comentario"
        git push
        hugo -d  ../alepeteporico.github.io/
        cd ../alepeteporico.github.io/
        git commit -am "$comentario"
        git push

    fi