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

~~~
debian@mrrobot:~$ sudo apt install certbot
~~~

* Tenemos que parar el servicio de nginx para dejar el puerto 80 libre.

~~~
debian@mrrobot:~$ sudo systemctl stop nginx.service
~~~

* Ahora si, vamos a generar los certificados.

~~~
root@mrrobot:~# certbot certonly --standalone -d www.alejandrogv.site
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator standalone, Installer None
Requesting a certificate for www.alejandrogv.site
Performing the following challenges:
http-01 challenge for www.alejandrogv.site
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/www.alejandrogv.site/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/www.alejandrogv.site/privkey.pem
   Your certificate will expire on 2022-07-17. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
~~~

~~~
root@mrrobot:~# certbot certonly --standalone -d python.alejandrogv.site
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator standalone, Installer None
Requesting a certificate for python.alejandrogv.site
Performing the following challenges:
http-01 challenge for python.alejandrogv.site
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/python.alejandrogv.site/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/python.alejandrogv.site/privkey.pem
   Your certificate will expire on 2022-07-17. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
~~~

* Vamos a comprobar los certificados que tenemos.

~~~
root@mrrobot:~# certbot certificates
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Found the following certs:
  Certificate Name: python.alejandrogv.site
    Serial Number: 366a35d4554012842c0a6e15479a6bbff69
    Key Type: RSA
    Domains: python.alejandrogv.site
    Expiry Date: 2022-07-17 09:08:03+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/python.alejandrogv.site/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/python.alejandrogv.site/privkey.pem
  Certificate Name: www.alejandrogv.site
    Serial Number: 312daa9a75a50f34e8519be31472dbb8656
    Key Type: RSA
    Domains: www.alejandrogv.site
    Expiry Date: 2022-07-17 09:05:58+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/www.alejandrogv.site/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/www.alejandrogv.site/privkey.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
~~~