+++
title = "Certificados Digitales"
description = ""
tags = [
    "ABD"
]
date = "2021-05-26"
menu = "main"
+++

* Primero obtendremos nuestro certificado digital en [la sede electrónica](https://www.sede.fnmt.gob.es/certificados/persona-fisica) siguiendo todos los pasos que se nos indican.

* Una vez tengamos nuestro certificado digital podemos importarlo a cualquier navegador, en mi caso quiero importarlo a un navegador firefox que tengo en mi sistema debian 10. Para ello nos dirigiremos a `preferencias > Privaciad y Seguridad > Certificados > Ver certificados` aquí aparecerá una vetana emergente donde podremos ver todos los certificados guardados que tenemos.

![todos](/certificados/1.png)

* Debemos dirigirnos a la pestaña de `sus certificados` e importar el nuestro.

![mios](/certificados/2.png)

* Tendremos que escribir una contraseña que especificamos al exportarlo y ya estará añadido.

![password](/certificados/3.png)

![certificado](/certificados/4.png)

#### ¿Cómo puedes hacer una copia de tu certificado?, ¿Como vas a realizar la copia de seguridad de tu certificado?. Razona la respuesta.

* En las imagenes anteriores podemos ver que existe la opción de `copiar todo`, esto copiaría nuestro certificado. Automáticamente nuestro navegador nos pedirá que protejamos el certificado copiado con una clave, ponemos una clave segura y como vimos antes al importar este certificado siempre necesitaremos introducir esa contraseña. Así es como exportariamos nuestra clave desde firefox.

#### Validacion del certificado.

* Vamos a validar nuestro certificado usando autofirma, un software que nos permite firmar nuestros certificados. Para hacerlo primero debemos descargar el paquete.

        alejandrogv@AlejandroGV:~$ wget https://estaticos.redsara.es/comunes/autofirma/currentversion/AutoFirma_Linux.zip

* También debemos, antes de instalar este software, instalar las dependencias necesarias.

        alejandrogv@AlejandroGV:~$ sudo apt install default-jdk libnss3-tools

* Ahora descomprimimos el paquete que descargamos antes e instalamos el `.deb` que dejará.

        alejandrogv@AlejandroGV:~$ unzip AutoFirma_Linux.zip

        alejandrogv@AlejandroGV:~$ sudo dpkg -i AutoFirma_1_6_5.deb

* Ahora iremos a la web que nos ofrece el gobierno español [VALIDe](https://valide.redsara.es/valide/validarCertificado/ejecutar.html) para validar nuestro certificado, clicariamos en `seleccionar certficado`, elegimos el programa de autofirma, seleccionamos nuestro certificado importado y le damos a aceptar.

![valide](/certificados/5.png)

![autofirma](/certificados/6.png)

![valide](/certificados/7.png)

![contraseña](/certificados/8.png)

![certificado](/certificados/9.png)

* Y ya tendriamos nuestro certificado validado.

![bien](/certificados/10.png)

#### Firma electrónica

* Vamos a crear dos ficheros que firmaremos con nuestro certificado digital.

        alejandrogv@AlejandroGV:~/prueba$ ls
        firmado1.txt  firmado2.txt

* Volveremos a VALIDe, pero esta vez nos dirigiremos al apartado `realizar firma`.

![realizar](/certificados/11.png)

* Seleccionaremos el fichero a firmar y nuestro certificado para firmarlo.

![fichero](/certificados/12.png)

![certificado](/certificados/13.png)

* Comprobamos que la firma se ha realiado correctamente.

![bien](/certificados/14.png)

#### Autentificación

* Podemos entrar en la pagina de la DGT para usar nuestro certificado.

![puntos](/certificados/15.png)

![bien](/certificados/16.png)