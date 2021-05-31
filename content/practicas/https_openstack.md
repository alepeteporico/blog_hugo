+++
title = "OpenStack: Configuración HTTPS"
description = ""
tags = [
    "SAD"
]
date = "2021-05-27"
menu = "main"
+++

### El siguiente paso de nuestro proyecto es configurar de forma adecuada el protocolo HTTPS en nuestro servidor web para nuestra aplicaciones web. Para ello vamos a emitir un certificado wildcard en la AC Gonzalo Nazareno utilizando para la petición la utilidad "gestiona".

* Lo primero que debemos hacer para llevarlo a cabo es dirigirnos a centos donde crearemos los directorios nesarios y crearemos una clave RSA.

        [centos@quijote ~]$ sudo mkdir /etc/ssl/private
        [centos@quijote ~]$ sudo chmod 700 /etc/ssl/private

        Generating RSA private key, 4096 bit long modulus (2 primes)
        ..........................++++
        ...++++
        e is 65537 (0x010001)

        [root@quijote ~]# chmod 400 /etc/ssl/private/openstack.key

* Nuestro siguiente paso será crear un fichero `.csr` que posteriormente será firmado por la autoridad certificadora de IES Gonzalo Nazareno.

        [root@quijote ~]# openssl req -new -key /etc/ssl/private/openstack.key -out /root/openstack.csr

* Ahora subiremos nuestro certificado a gestiona para que sea firmado por la unidad certificadora de IES Gonzalo Nazareno.

![cert](/https_openstack/1.png)

* Cuando esté firmado lo descargamos.

![cert](/https_openstack/2.png)

* Copiamos este certificado en Quijote.

        [centos@quijote ~]$ scp alejandrogv@172.29.0.34:/home/alejandrogv/Descargas/openstack.crt .

* Lo movemos a la carpeta de certificados que creamos anteriormente

        [centos@quijote ~]$ sudo mv openstack.crt /etc/ssl/certs/

* También debemos descargar en la misma ubicación el CA del Gonzalo Nazareno.

        [centos@quijote certs]$ sudo scp alejandrogv@172.29.0.34:/home/alejandrogv/Descargas/gonzalonazareno.crt .

* Ahora crearemos un virtual host, la caracteristica principal del mismo es que tendrá dos directivas. Una para acceder desde el puerto 80 y otra desde el 443. Aunque realmente cambiaremos la configuración del primero para solamente definir el ServerName y que directamente se redireccione a la conexión 443 (https) que es la segura.

* En el bloque donde definimos la conexión https añadiremos la ruta de los certificados necesarios, vemos la configuración del virtual host a continuación.

        <VirtualHost *:80>
            ServerName www.alegv.gonzalonazareno.org
        
                Redirect 301 / https://www.alegv.gonzalonazareno.org/
        
            ErrorLog /var/www/alegv/log/error.log
            CustomLog /var/www/alegv/log/requests.log combined
        </VirtualHost>
        
        <IfModule mod_ssl.c>
            <VirtualHost _default_:443>
                ServerName www.alegv.gonzalonazareno.org
                DocumentRoot /var/www/alegv 
        
                <Proxy \"unix:/run/php-fpm/www.sock|fcgi://php-fpm\">
                    ProxySet disablereuse=off
                </Proxy>
        
                <FilesMatch \.php$>
                    SetHandler proxy:fcgi://php-fpm
                </FilesMatch>
        
                ErrorLog /var/www/alegv/log/error.log
                CustomLog /var/www/alegv/log/requests.log combined
        
                SSLEngine on
        
                SSLCertificateFile	/etc/ssl/certs/openstack.crt
                SSLCertificateKeyFile   /etc/ssl/private/openstack.key
                SSLCACertificateFile    /etc/ssl/certs/gonzalonazareno.crt
            </VirtualHost>
        </IfModule>

* Ahora debemos instalar el módulo de ssl para apache.

        [centos@quijote ~]$ sudo dnf install mod_ssl

* Para que SELinux no nos de problemas usamos el siguiente comando sobre los certificados que tenemos.

        [centos@quijote ~]$ sudo restorecon /etc/ssl/certs/openstack.crt
        [centos@quijote ~]$ sudo restorecon /etc/ssl/certs/gonzalonazareno.crt

* Lo que debemos hacer ahora es permitir que apache escuche por el puerto 443, para ello iremos a su fichero de configuración `/etc/httpd/conf/httpd.conf` y añadimos la siguiente línea.

        Listen 443

* Ahora podemos reiniciar el servicio.

        [centos@quijote ~]$ sudo systemctl restart httpd

* Comprobamos que ahora al acceder a nuestro sitio web se accede mediante una conexión segura https.

![https](/https_openstack/3.png)

* Podemos visualizar información sobre la seguridad de nuestra página y el certificado.

![cert](/https_openstack/4.png)