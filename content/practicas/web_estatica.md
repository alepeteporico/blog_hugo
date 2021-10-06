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

# **jekyll**

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

* Ahora escogemos una plantilla de [la pagina oficial de jekyll](https://jekyllthemes.io/) en mi caso es escogido el tema [minimal mistakes](https://github.com/mmistakes/minimal-mistakes)

* Debemos leer en el repositorio el fichero `README`, ahí se nos darán los pasos necesarios para instalar este tema.
