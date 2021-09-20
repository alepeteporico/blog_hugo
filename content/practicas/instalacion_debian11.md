+++
title = "Instalación de debian 11 con LVM"
description = ""
tags = [
    "SO"
]
date = "2021-09-16"
menu = "main"
+++

---


* Empezamos la instalación y seguimos todos los pasos normalmente hasta llegar a la configuración de los discos, la haremos manualmente y en mi caso he creado una máquina virtual para simular lo que hice en mi máquina anfitriona, para ello he creado una partición sin usar simulando que tengo en ella una partición con Windows 10.

![](/instalacion/1.png)

* Seguidamente elegiremos la opción de "Configurar el gestor de volúmenes lógicos" y crearemos un grupo de volúmenes.
![](/instalacion/2.png)

* Elegimos el espacio libre que teníamos en el disco, este será nuestro grupo de volúmenes, aunque podríamos primero particionar este espacio libre y después crear un grupo de volúmenes con estas particiones, nosotros lo haremos al revés.
![](/instalacion/3.png)

* Ahora dentro de este grupo de volúmenes crearemos de volúmenes lógicos, uno para el sistema y otro para la SWAP
![](/instalacion/9.png)

![](/instalacion/4.png)

* Tenemos creados los volúmenes lógicos como hemos visto en la anterior captura, pero debemos asignarle para  que la usaremos y donde las montaremos.
![](/instalacion/5.png)
![](/instalacion/6.png)
![](/instalacion/7.png)

* Una vez hecho esto ya tendremos configurado LVM en nuestro sistema como queremos, no hemos usado todo el espacio que teníamos, por lo que mas tarde  podremos aumentar el tamaño de alguno de los volúmenes.
![](/instalacion/8.png)

* Seguiremos la instalación con normalidad y arrancaremos nuestro debian buster, en mi caso tuve un problema que al parecer es muy común. Al arrancar llegaba un momento en que el sistema dejaba de responder, aparecía una pantalla en negro con el cursor arriba a la izquierda, sin posibilidad de hacer nada. Para arreglarlo entre en modo recovery y deshabilite los drivers de nouveau, que al parecer daban conflicto. para hacerlo modifique el fichero "/etc/default/grub" y modificaremos las dos líneas que vemos a continuación tal y como aparecen.

        GRUB_CMDLINE_LINUX_DEFAULT="nouveau.modeset=0"
        GRUB_CMDLINE_LINUX="nouveau.modeset=0"

* Con este cambio ya arrancará nuestro sistema con normalidad y podremos acceder al entorno gráfico, nuestra primera tarea dentro de el será instalar el firmware de la tarjeta inalámbrica, la cual al principio de la instalación nos advirtió que no se instalarían, aquí vemos la imagen.
![](/instalacion/11.png)

* Para instalarlo deberemos añadir en el fichero sources.list los repositorios de backports e instalar el firmware que corresponde con el siguiente comando.

        apt -t buster-backports install firmware-iwlwifi


* Aparentemente solo faltarían dos cosas por estar a punto, los controladores de la GPU Nvidia y la configuración del network manager. Veamos que le ocurría a network manager, este parecía estar deshabilitado. Aunque el equipo tenía conexión el error exacto que daba network manager era "cableado sin gestionar" y en efecto no podía gestionarse nada desde network manager. Para solucionar el problema debemos editar el fichero "/etc/NetworkManager/NetworkManager.conf" y cambiar a true la opción managed. Una vez hecho esto reiniciamos el servicio y podremos comprobar que todo funciona correctamente.

        [main]
        plugins=ifupdown,keyfile
        
        [ifupdown]
        managed=true

* Por último tenemos los drivers de la gráfica, los cuales no he sido capaz de instalar, lo he intentado de varias formas según las páginas oficiales de debian, entre ellas descargar el paquete "nvidia-detect" que detecta que gráfica tienes y que driver te convendría instalar para usarla en debian, aunque instalé el recomendado daba muchos conflictos con varias cosas, entre ellas el nouveau, aunque hemos hecho que debian no cargue el modulo. Quizás se podría solucionar el problema instalando drivers no oficiales, instalando un kernel mas nuevo u de otras formas no oficiales. Sin embargo dejaremos al sistema trabajando con gráfica integrada del procesador, ya que funciona bien y no necesitaremos más para nuestro caso.