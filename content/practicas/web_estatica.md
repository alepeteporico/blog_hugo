+++
title = "Implantación y despliegue de una aplicación web estática 2021"
description = ""
tags = [
    "IWEB"
]
date = "2021-09-29"
menu = "main"
+++

---

### Vamos a realizar e implementar una aplicación web estática, para ello usaremos el generador de páginas estáticas `jekyll` y usaremos para implementarlo `surge`.

## jekyll

* Para la instalación de jekyll primero debemos asegurarnos de tener instalado ruby y algunas dependencias ya que la aplicación está escrita en este lenguaje.

~~~
sudo apt install ruby ruby-dev
~~~

* Y ahora si podemos instalar jekyll.

~~~
sudo gem install bundler jekyll
~~~

* Ahora crearemos nuestro sitio web en el entorno de desarrollo

~~~
jekyll new jekyll_dinamico
~~~

* Vamos a visualizar el contenido de este sitio que se nos ha generado por defecto.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/jekyll/jekyll_dinamico$ tree
.
├── 404.html
├── about.markdown
├── _config.yml
├── Gemfile
├── Gemfile.lock
├── index.markdown
├── _posts
│   └── 2021-09-29-welcome-to-jekyll.markdown
└── README.md

1 directory, 8 files
~~~

* Vamos a ejecutar esta web

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/jekyll/jekyll_dinamico$ bundle exec jekyll serve
Configuration file: /home/alejandrogv/Escritorio/ASIR/IWEB/jekyll/jekyll_dinamico/_config.yml
            Source: /home/alejandrogv/Escritorio/ASIR/IWEB/jekyll/jekyll_dinamico
       Destination: /home/alejandrogv/Escritorio/ASIR/IWEB/jekyll/jekyll_dinamico/_site
 Incremental build: disabled. Enable with --incremental
      Generating... 
       Jekyll Feed: Generating feed for posts
                    done in 0.366 seconds.
 Auto-regeneration: enabled for '/home/alejandrogv/Escritorio/ASIR/IWEB/jekyll/jekyll_dinamico'
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
~~~

* Si entramos a la URL que aparece podremos ver la pagina de prueba.

![ejemplo](/web_estatica2021/1.png)

* Ya hemos visto la web que se crea por defecto y que podriamos modifcar, sin embargo, nosotros vamos a escoger una plantilla de [la pagina oficial de jekyll](https://jekyllthemes.io/) en mi caso es escogido el tema [minimal mistakes](https://github.com/daattali/beautiful-jekyll.git)

* Debemos leer en el repositorio el fichero `README`, ahí se nos darán los pasos necesarios para instalar este tema.

* El primer paso para este tema sera instalar dos gems de ruby.

~~~
sudo gem install jekyll bundler
~~~

* Clonamos el repositorio.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/jekyll$ git clone https://github.com/daattali/beautiful-jekyll.git
Clonando en 'beautiful-jekyll'...
remote: Enumerating objects: 3847, done.
remote: Total 3847 (delta 0), reused 0 (delta 0), pack-reused 3847
Recibiendo objetos: 100% (3847/3847), 4.68 MiB | 2.07 MiB/s, listo.
Resolviendo deltas: 100% (2139/2139), listo.
~~~

* En el fichero `_config.yml` añadimos este tema al theme.

~~~
theme: beautiful-jekyll-theme
~~~

* Si quisiermos iniciar el servidor vemos que nos da un error.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/jekyll/beautiful-jekyll$ bundle exec jekyll server
Could not find gem 'rake (~> 12.0)' in locally installed gems.

The source contains the following gems matching 'rake':
  * rake-13.0.3
  * rake-13.0.6
~~~

* Como nos indica debemo ejecutar `bundle install` para instalar las gemas necesarias.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/jekyll/beautiful-jekyll$ bundle install
Fetching gem metadata from https://rubygems.org/..........
Resolving dependencies...
Following files may not be writable, so sudo is needed:
  /usr/local/bin
  /var/lib/gems/2.7.0
  /var/lib/gems/2.7.0/build_info
  /var/lib/gems/2.7.0/cache
  /var/lib/gems/2.7.0/doc
  /var/lib/gems/2.7.0/extensions
  /var/lib/gems/2.7.0/gems
  /var/lib/gems/2.7.0/plugins
  /var/lib/gems/2.7.0/specifications
Fetching rake 12.3.3
...
...
...
~~~

* Al ejectuar este servidor vemos la plantilla que hemos descargado.

![ejemplo](/web_estatica2021/1.png)

* Modificamos un poco los ficheros, la pagina principal estará en el fichero `_config.yml` y podremos añadir posts en la carpeta `_posts`.

![ejemplo](/web_estatica2021/3.png)

* Hemos añadido a nuestro github este [repositorio](https://github.com/alepeteporico/blog_jekyll)

* Pero para poder implementar nuestra web debemos generar el contenido estatico.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/jekyll/blog_jekyll$ bundle exec jekyll build
Configuration file: /home/alejandrogv/Escritorio/ASIR/IWEB/jekyll/blog_jekyll/_config.yml
            Source: /home/alejandrogv/Escritorio/ASIR/IWEB/jekyll/blog_jekyll
       Destination: /home/alejandrogv/Escritorio/ASIR/IWEB/jekyll/blog_jekyll/_site
 Incremental build: disabled. Enable with --incremental
      Generating... 
                    done in 0.934 seconds.
 Auto-regeneration: disabled. Use --watch to enable.
~~~

* esto creará una carpeta llamada `_site` que será la que implementemos.

## Surge

* Ahora tenemos que implementar nuestra web de forma estatica, esto lo haremos mediante surge, para ello lo instalaremos primero.

~~~
sudo npm install --global surge
~~~

* Y la implementamos, tendremos que especificar el directorio y el dominio.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/jekyll/blog_jekyll$ surge

   Running as tojandro@gmail.com (Student)

        project: /home/alejandrogv/Escritorio/ASIR/IWEB/jekyll/blog_jekyll/
         domain: alepeteporico.surge.sh
         upload: [====================] 100% eta: 0.0s (87 files, 4038235 bytes)
            CDN: [====================] 100%
     encryption: *.surge.sh, surge.sh (41 days)
             IP: 138.197.235.123

   Success! - Published to alepeteporico.surge.sh
~~~

* Y ya estará desplegada nuestra web.

![ejemplo](/web_estatica2021/3.png)

## Script

* Este es el script que automatiza la generacion estatica, despliega y hace un commit en el repositorio de github.

~~~
read -p "¿Cual va a ser el commit? " comentario

cd blog_jekyll
git add .
git commit -am "$comentario"
git push

bundle exec jekyll build
surge _site/ alepeteporico.surge.sh
~~~