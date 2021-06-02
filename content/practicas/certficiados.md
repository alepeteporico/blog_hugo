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

#### HTTPS 

* Crearemos una clave privada que asociaremos a nuestra solicitud de firma.

        root@https:~# openssl genrsa 4096 > /etc/ssl/private/alegv.key
        Generating RSA private key, 4096 bit long modulus (2 primes)
        ............++++
        ......++++
        e is 65537 (0x010001)

* Con esta clave generaremos un fichero csr.

        openssl req -new -key /etc/ssl/private/alegv.key -out alegv.csr      

* Una vez se nos firme nuestro certificado como veremos posteriormente podemos añadirlo a nuestra página, primero debemos configurar el módulo de ssl de apache configurando el fichero `/etc/apache2/sites-available/default-ssl.conf`.

        <IfModule mod_ssl.c>
                <VirtualHost _default_:443>
                        ServerAdmin webmaster@localhost
                        ServerName alegv.iesgn.org
                        DocumentRoot /var/www/iesgn

                        ErrorLog ${APACHE_LOG_DIR}/error.log
                        CustomLog ${APACHE_LOG_DIR}/access.log combined

                        SSLEngine on

                        SSLCertificateFile      /etc/ssl/certs/alegv.crt
                        SSLCertificateKeyFile /etc/ssl/private/alegv.key
                        SSLCACertificateFile /etc/ssl/certs/prueba.pem

                        <FilesMatch \"\.\(cgi|shtml|phtml|php)\$\">
                                        SSLOptions +StdEnvVars
                        </FilesMatch>
                        <Directory /usr/lib/cgi-bin>
                                        SSLOptions +StdEnvVars
                        </Directory>
                </VirtualHost>
        </IfModule>

* Y en el virtual host deberíamos añadir la siguiente línea:

        Redirect 301 / https://alegv.iesgn.com/

----------------------------------

* Vamos a crear los directorios necesarios para realizar esta parte.

        root@https2:/# tree CA/
        CA/
        ├── certs
        ├── crl
        ├── nuevos
        └── privado

* Debemos crear un fichero que nos servira como base de datos sobre los certificados creados.

        root@https2:/CA# touch index.txt

* También copiaremos un fichero llamado `openssl.cnf`:

        root@https2:/CA# cp /etc/ssl/openssl.cnf /CA

* Ahora podemos crear nuestro certificado autofirmado.

        root@https:/CA# openssl req -config openssl.cnf -new -x509 -extensions v3_ca -keyout privado/ca.key -out ./certs/caalegv.crt

* Vamos a modificar nuestro fichero openssl para personalizar los directorios que se usan.

        [ CA_default ]

        dir             = /CA           # Where everything is kept
        certs           = $dir/certs            # Where the issued certs are kept
        crl_dir         = $dir/crl              # Where the issued crl are kept
        database        = $dir/index.txt        # database index file.
        #unique_subject = no                    # Set to 'no' to allow creation of
                                                # several certs with same subject.
        new_certs_dir   = $dir/nuevos           # default place for new certs.

        certificate     = $dir/certs/ca.crt 
        serial          = $dir/serial 
                                                # must be commented out to leave a V1 CRL
        crl             = $dir/crl.pem 
        private_key     = $dir/privado/ca.key 

        x509_extensions = usr_cert

* Vamos a generar nuestro par de calves.

        root@https2:/CA# openssl req -new -newkey rsa:2048 -keyout privado/caprueba.key -out caclave.pem -config ./openssl.cnf

* Posteriormente autofirmaremos nuestro certificado.

        root@https2:/CA# openssl ca -create_serial -out cacerts.pem -days 365 -keyfile privado/caprueba.key -selfsign -extensions v3_ca -config ./openssl.cnf -infiles caclave.pem
        Using configuration from ./openssl.cnf
        Enter pass phrase for privado/caprueba.key:
        Check that the request matches the signature
        Signature ok
        Certificate Details:
                Serial Number: 1 (0x1)
                Validity
                    Not Before: Jun  2 18:17:01 2021 GMT
                    Not After : Jun  2 18:17:01 2022 GMT
                Subject:
                    countryName               = ES
                    stateOrProvinceName       = Sevilla
                    organizationName          = Prueba SL
                    organizationalUnitName    = prueba
                    commonName                = alejandro
                    emailAddress              = prueba@yahoo.es
                X509v3 extensions:
                    X509v3 Subject Key Identifier: 
                        B4:A9:FB:C0:3B:A8:BB:74:97:93:6F:6E:B9:C7:AB:2D:E6:61:F4:BD
                    X509v3 Authority Key Identifier: 
                        keyid:B4:A9:FB:C0:3B:A8:BB:74:97:93:6F:6E:B9:C7:AB:2D:E6:61:F4:BD

                    X509v3 Basic Constraints: critical
                        CA:TRUE
        Certificate is to be certified until Jun  2 18:17:01 2022 GMT (365 days)
        Sign the certificate? [y/n]:y


        1 out of 1 certificate requests certified, commit? [y/n]y
        Write out database with 1 new entries
        Data Base Updated

* Vamos a ver todos los ficheros que se han generado.

        root@https2:/CA# ls
        cacerts.pem  certs  index.txt	    index.txt.old  openssl.cnf	serial
        caclave.pem  crl    index.txt.attr  nuevos	   privado	serial.old

* firmamos el certificado.

        root@https2:/CA# openssl ca -config openssl.cnf -out certs/caalegv.crt -infiles nuevos/alegv.csr 
        Using configuration from openssl.cnf

* Ahora enviariamos el certificado firmado.