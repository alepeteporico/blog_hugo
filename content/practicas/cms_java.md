+++
title = "Despliegue de CMS java"
description = ""
tags = [
    "IWEB"
]
date = "2021-05-04"
menu = "main"
+++

* Elegiremos instalar la aplicación con Guacamole, para empezar instalaremos la paquetería necesaria.

        vagrant@cmsjava:~$ sudo apt install build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavformat-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libvorbis-dev libwebp-dev

* Descargaremos la aplicación del sitio oficial.

        vagrant@cmsjava:~$ wget http://archive.apache.org/dist/guacamole/1.2.0/source/guacamole-server-1.2.0.tar.gz

* Descomprimimos la carpeta que acabamos de descargar.

        vagrant@cmsjava:~$ tar -zxf guacamole-server-1.2.0.tar.gz
        vagrant@cmsjava:~$ ls
        guacamole-server-1.2.0

* Entraremos y lo instalaremos siguiendo los siguientes pasos.

        vagrant@cmsjava:~/guacamole-server-1.2.0$ ./configure --with-init-dir=/etc/init.d

        vagrant@cmsjava:~/guacamole-server-1.2.0$ make

        vagrant@cmsjava:~/guacamole-server-1.2.0$ sudo make install

        vagrant@cmsjava:~/guacamole-server-1.2.0$ sudo ldconfig

* Reiniciamos el sistema y hablitamos el servicio de guacamole.

        vagrant@cmsjava:~/guacamole-server-1.2.0$ sudo systemctl daemon-reload 

        vagrant@cmsjava:~/guacamole-server-1.2.0$ sudo systemctl start guacd.service 

        vagrant@cmsjava:~/guacamole-server-1.2.0$ sudo systemctl enable guacd.service 
        guacd.service is not a native service, redirecting to systemd-sysv-install.
        Executing: /lib/systemd/systemd-sysv-install enable guacd

* Debemos descargar también un fichero para apache y moverlo a la carpeta que especifico abajo.

        vagrant@cmsjava:~$ wget -O 'guacamole.war' 'http://archive.apache.org/dist/guacamole/1.2.0/binary/guacamole-1.2.0.war'

        vagrant@cmsjava:~$ sudo mv guacamole.war /var/lib/tomcat9/webapps/

* Reiniciamos los servicios de tomcat y guacamole.

        vagrant@cmsjava:~$ sudo systemctl restart tomcat9 guacd

* Crearemos un fichero dentro de `/etc/guacamole` llamado `guacamole.properties` al que daremos la siguiente configuración y creamos un enlace simbólico.

        # Hostname and port of guacamole proxy
        guacd-hostname: localhost
        guacd-port:     4822
        # Auth provider class (authenticates user/pass combination, needed if using the provided $
        user-mapping: /etc/guacamole/user-mapping.xml
        auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
        basic-user-mapping: /etc/guacamole/user-mapping.xml

        vagrant@cmsjava:~$ sudo ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat9/.guacamole

* Crearemos el fichero `user-mapping.xml` en la misma ubicación donde especificaremos el usuario y contraseña de la aplicación y una maquina de prueba con protocolo ssh.

        <user-mapping>
                <authorize 
                 username="admin" 
                 password="admin"
                 encoding="md5">
                        <connection name="remoto">
                                <protocol>ssh</protocol>
                                <param name="hostname">192.168.100.140</param>
                                <param name="port">22</param>
                                <param name="username">alegv</param>
                                <param name="password">prueba</param>
                        </connection>
                </authorize>
        </user-mapping>

* Cambiaremos los permisos necesarios y volveremos a reiniciar el servicio.

        vagrant@cmsjava:~$ sudo chmod 600 /etc/guacamole/user-mapping.xml
        vagrant@cmsjava:~$ sudo chown tomcat:tomcat /etc/guacamole/user-mapping.xml
        vagrant@cmsjava:~$ sudo systemctl restart tomcat9 guacd

* Ahora activaremos varios modulos de apache.

        vagrant@cmsjava:~$ sudo a2enmod proxy proxy_http headers proxy_wstunnel

* Y por último crearemos un virtual host cuyo fichero de configuración tendrá el siguiente aspecto.

        <VirtualHost *:80>
              ServerName guacamole.alegv.com

              ErrorLog ${APACHE_LOG_DIR}/guacamole_error.log
              CustomLog ${APACHE_LOG_DIR}/guacamole_access.log combined

              <Location />
                  Require all granted
                  ProxyPass http://localhost:8080/guacamole/ flushpackets=on
                  ProxyPassReverse http://localhost:8080/guacamole/
              </Location>

             <Location /websocket-tunnel>
                 Require all granted
                 ProxyPass ws://localhost:8080/guacamole/websocket-tunnel
                 ProxyPassReverse ws://localhost:8080/guacamole/websocket-tunnel
             </Location>

             Header always unset X-Frame-Options
        </VirtualHost>

* Después de añadir a nuestro `/etc/hosts` la ip podremos entrar.

![guacamole](/guacamole/1.png)