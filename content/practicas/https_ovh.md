+++
title = "HTTPS OVH"
description = ""
tags = [
    "ASO"
]
date = "2022-04-17"
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
root@mrrobot:~# certbot certonly --standalone -d django.alejandrogv.site
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator standalone, Installer None
Requesting a certificate for django.alejandrogv.site
Performing the following challenges:
http-01 challenge for django.alejandrogv.site
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/django.alejandrogv.site/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/django.alejandrogv.site/privkey.pem
   Your certificate will expire on 2022-07-19. To obtain a new or
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
  Certificate Name: django.alejandrogv.site
    Serial Number: 473148e2b4e29b9e07d399fbdd8502de63b
    Key Type: RSA
    Domains: django.alejandrogv.site
    Expiry Date: 2022-07-19 14:34:56+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/django.alejandrogv.site/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/django.alejandrogv.site/privkey.pem
  Certificate Name: www.alejandrogv.site
    Serial Number: 312daa9a75a50f34e8519be31472dbb8656
    Key Type: RSA
    Domains: www.alejandrogv.site
    Expiry Date: 2022-07-17 09:05:58+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/www.alejandrogv.site/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/www.alejandrogv.site/privkey.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
~~~

* Ya tenemos nuestro certificados alojados en `/etc/letsencrypt/live/` veamos un ejemplo.

~~~
root@mrrobot:~# ls /etc/letsencrypt/live/django.alejandrogv.site/
README	cert.pem  chain.pem  fullchain.pem  privkey.pem
~~~

* Vamos a decir para que sirven cada uno de los ficheros.

- `cert.pem`: Contiene nuestras claves públicas, es nuestro certificado tal cual.

- `chain.pem`: Es el certificado de Let's Encrypt con la que ha sido firmado nuestro certificado, así los clientes podrán comprobar la firma de nuestro certificado.

- `fullchain.pem`: Es una unión de los dos anteriores ficheros, normalmente usaremos solo este, ya que es más sencillo.

- `privkey.pem`: nuestra clave privada.

* Nos dirigimos a nuestros virtual host, el primero que configuraremos será el de `www.alejandrogv.site`, para ello las primeras líneas del fichero deberían estar así.

~~~
server {
        listen 443 ssl http2;
        listen [::]:443 http2;

        ssl on;
        ssl_certificate /etc/letsencrypt/live/www.alejandrogv.site/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/www.alejandrogv.site/privkey.pem;
~~~

* Reiniciamos nginx y comprobamos que accedemos mediante https.

![prueba](/https_vps/1.png)

* Hacemos lo mismo con el sitio de django.

![prueba](/https_vps/2.png)

* Comprobamos que tiene el certificado de Let's Encrypt.

![certificado](/https_vps/3.png)

* Si queremos que se redirija a https cuando alguien escriba la dirección en http crearemos un nuevo virtual host con el siguiente contenido.

~~~
server {
        listen 80;
        listen [::]:80;

        server_name django.alejandrogv.site;

    return 301 https://$host$request_uri;
}
~~~

* Comprobemos que nuestro cliente de escritorio de nextloud también accede por https.

![certificado](/https_vps/4.png)

### ¿Qué función tiene el cliente ACME?

* es un protocolo estándar para automatizar la validación, instalación y gestión de dominios de certificados.

### ¿Qué pruebas realiza Let’s Encrypt para asegurar que somos los administrados del sitio web?

* Certbot coloca un token en un fichero que sea accesible por el servidor web que estamos configurando y lo firma con su clave privada. Entonces Let's Encrypt intenta acceder a este fichero y verificar la firma, si puede hacerlo se valida que somos los administradores del dominio.

### ¿Se puede usar el DNS para verificar que somos administradores del sitio?

* Podriamos hacer que Let's Encrypt confirmara que somos los administradores del dominio DNS, esto lo hará creando un registro en la zona con una información especifica.