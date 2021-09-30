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