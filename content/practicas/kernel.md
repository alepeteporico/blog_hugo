+++
title = "Compilación de un kérnel linux a medida"
description = ""
tags = [
    "ASO"
]
date = "2021-09-17"
menu = "main"
+++

* Vamos a necesitar instalar cierta paquetería como vemos a continuación.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ sudo apt install build-essential qtbase5-dev

* Necesitamos saber que versión del kernel estamos usando.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ uname -r
        5.10.0-8-amd64

* Descargaremos la versión de nuestro kernel desde [la página oficial](https://mirrors.edge.kernel.org/pub/linux/kernel/)

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.tar.gz

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ ls
        linux-5.10.tar.gz

* Descomprimos este archivo y el resultado será una carpeta con muchisima información.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ tar xzvf linux-5.10.tar.gz

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ cd linux-5.10/
        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ ls
        arch   COPYING  Documentation  include  Kbuild   lib          Makefile  README   security  usr
        block  CREDITS  drivers        init     Kconfig  LICENSES     mm        samples  sound     virt
        certs  crypto   fs             ipc      kernel   MAINTAINERS  net       scripts  tools

* Ejecutaremos el comando `make oldconfig` para generar el fichero `.config` donde se especifican todos los módulos entre otra información, nos preguntará sobre algunos si queremos quitarlos o no, nosotros los quitaremos todos.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ make oldconfig

* Vamos a visualizar que módulos hay ahora mismo enlazados estáticamente y dinámicamente.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=y' .config | wc -l
        2186

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=m' .config | wc -l
        3743

* Vemos que tenemos 2185 estáticos y 3743 dinámicos, quitar esto a mano sería un proceso bastante largo, en lugar de ello podemos hacer uso de la herramienta `make localmodconfig` que comprobará que componentes se están usando en nuestro sistema y eliminará el resto. Nuevamente habŕa algunos que nos pregunte especificamente si queremos quitarlos, también los eliminaremos.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ make localmodconfig

* Volvamos a visualizar los módulos activos y comprobaremos que el número ha bajado considerablemente.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=y' .config | wc -l
        1592
        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=m' .config | wc -l
        278

* Para ir quitando los modulos que veamos innecesarios usamos `make xconfig` nos aparecerá una ventana gráfica donde podremos ir quitando módulos desmarcandolos y ahora veremos como compilar este kernel cuando lo veamos necesario. Este proceso lo realizaremos poco a poco, quitaremos algunos módulos, compilaremos y probaremos que el sistema sigue funcionando.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ make xconfig
          UPD     scripts/kconfig/.qconf-cfg
          MOC     scripts/kconfig/qconf.moc
          HOSTCXX scripts/kconfig/qconf.o
          HOSTLD  scripts/kconfig/qconf
        scripts/kconfig/qconf  Kconfig
        Warning: Ignoring XDG_SESSION_TYPE=wayland on Gnome. Use QT_QPA_PLATFORM=wayland to run on Wayland anyway.

![xconfig]()

* Cada vez que realizemos este proceso, sería bueno hacer una copia de seguridad del fichero `.config` antes, así si el sistema no carga correctamente podríamos usar la configuración anterior. Vamos a comprobar el fichero `.config` después de quitar algunos módulos.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-4.19.16$ egrep '=y' .config | wc -l
        1576
        
* Como vemos el número ha disminuido. Ahora vamos a compilar este kernel.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-4.19.16$ make -j12 bindeb-pkg

* Una vez compilado tendremos como resultado un archivo `.deb`, veamos cuanto pesa para compararlo más adelante con el kernel final.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ ls -lh linux-image-4.19.16_4.19.16-1_amd64.deb 
        -rw-r--r-- 1 alejandrogv alejandrogv 9,2M may 29 18:56 linux-image-4.19.16_4.19.16-1_amd64.deb

* Después de haber quitado algunos modulos tenemos un kernel resultante de 9,2 MB ahora solo lo instalariamos con `dpkg -i` y al reiniciar el sistema entramos con el kernel que acabamos de compilar.

* Después de varias pruebas tenemos nuestro kernel compilado lo mas simple posible, vamos a contar nuevamente los módulos del fichero `.config`

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-4.19.16$ egrep '=y' .config | wc -l
        610
        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-4.19.16$ egrep '=m' .config | wc -l
        89

* Si vemos también el kernel compilado como vimos anteriormente, notaremos que pesa bastante menos, en concreto 5 MB menos.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ ls -lh linux-image-4.19.16_4.19.16-1_amd64.deb 
        -rw-r--r-- 1 alejandrogv alejandrogv 4,0M may 30 19:45 linux-image-4.19.16_4.19.16-1_amd64.deb