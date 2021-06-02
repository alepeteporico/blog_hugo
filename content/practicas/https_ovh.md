+++
title = "HTTPS OVH"
description = ""
tags = [
    "ASO"
]
date = "2021-06-01"
menu = "main"
+++

### Explica los pasos fundamentales para la creación del certificado. Especificando los campos que has rellenado en el fichero CSR.

* Para este cometido usaremos el servicio letsencrypt, esta unidad certificadora hace use del protocolo ACME que lleva a cabo dos sencillos pasos mediante un agente llamadao `certbot` los pasos son:

1. Validación del dominio. Tenemos que demostrar que somos administradores del dominio en el que queremos generar este certificado, esto se puede hacer de dos formas:

* Creando un fichero de configuración en una ruta determinada, si la autoridad certificadora puede acceder por el puerto 80 y verificar este fichero y validar las firmas de las claves que se generarían para hacer dicha conexión, entonces verificará que somos administradores del dominio.

* También podemos crear un registro en el DNS con una información especifica y la autoridad certificadora podrá comprobar que administramos el dominio DNS.

2. Solicitud del certificado. Una vez hecha la validación se firmará el certificado y letsencrypt generará un certificado para nuestro dominio. Se verifica la firma de dicho certificado y si todo sale bien se nos envia nuestro certificado.

--------------------------------------------

* Vamos a proceder a realizar nuestro certificado, para ello primero instalamos certbot

        root@sputnik:~# apt install certbot

* Tenemos que parar el servicio de nginx para dejar el puerto 80 libre.

        root@sputnik:~# systemctl stop nginx

* Ahora si, vamos a generar el certificado y rellenar la información, lo primero que nos pedirá será el correo electrónico.

        root@sputnik:~# certbot certonly --standalone -d www.iesgn06.es
        Saving debug log to /var/log/letsencrypt/letsencrypt.log
        Plugins selected: Authenticator standalone, Installer None
        Enter email address (used for urgent renewal and security notices) (Enter 'c' to
        cancel): tojandro@gmail.com

* Tenemos que aceptar los terminos.

        Please read the Terms of Service at
        https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
        agree in order to register with the ACME server at
        https://acme-v02.api.letsencrypt.org/directory
        - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        (A)gree/(C)ancel: A

* Por último no dejaremos que compartan nuestro correo e inforamción.

        Would you be willing to share your email address with the Electronic Frontier
        Foundation, a founding partner of the Let's Encrypt project and the non-profit
        organization that develops Certbot? We'd like to send you email about our work
        encrypting the web, EFF news, campaigns, and ways to support digital freedom.
        - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        (Y)es/(N)o: N

