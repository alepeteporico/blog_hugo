+++
title = "Pull Request"
description = ""
tags = [
    "SO"
]
date = "2021-09-19"
menu = "main"
+++

---

### Vamos a hacer un pull request de un repositorio perteneciente a otra persona. 

* Para ello debemos hacer un fork en github de su repositorio y entonces clonar ese fork que ahora está en nuestro repositorio, una vez clonado entramos en el repositorio y creamos una nueva rama.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/prueba-pr-asir$ git checkout -b mi_proyecto
Cambiado a nueva rama 'mi_proyecto'
~~~

* Después de realizar los cambios que necesitemos los agregamos a nuestra rama.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/prueba-pr-asir$ git add .
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/prueba-pr-asir$ git commit -am "cambios"
[mi_proyecto dff10a7] cambios
 2 files changed, 10 insertions(+)
 create mode 100644 files/agv.md
~~~

* Ahora enviamos los cambios a nuestro github.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/prueba-pr-asir$ git push origin mi_proyecto
Enumerando objetos: 8, listo.
Contando objetos: 100% (8/8), listo.
Compresión delta usando hasta 12 hilos
Comprimiendo objetos: 100% (5/5), listo.
Escribiendo objetos: 100% (5/5), 632 bytes | 632.00 KiB/s, listo.
Total 5 (delta 2), reusado 0 (delta 0), pack-reusado 0
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
remote: 
remote: Create a pull request for 'mi_proyecto' on GitHub by visiting:
remote:      https://github.com/alepeteporico/prueba-pr-asir/pull/new/mi_proyecto
remote: 
To github.com:alepeteporico/prueba-pr-asir.git
 * [new branch]      mi_proyecto -> mi_proyecto
~~~

* Ahora tendremos en nuestro repositorio en github una opción para hacer el pull-request, simplemente le damos y ya se hará nuestra petición.

![pull request](/pull_request/1.png)