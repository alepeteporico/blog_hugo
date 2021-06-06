+++
title = "Proxy, proxy inverso y balanceadores de carga"
description = ""
tags = [
    "HLC"
]
date = "2021-06-06"
menu = "main"
+++

* Primero usaremos squid para instalar un proxy.

        vagrant@proxy:~$ sudo apt install squid

* Modificamos el fichero `/etc/squid/squid.conf` para definir las direcciones y puertos que permitiremos y el puerto de funcionamiento.

        acl localnet src 10.0.0.0/24
        acl localnet src 172.22.100.0/24

        acl SSL_ports port 443
        acl Safe_ports port 80          # http
        acl Safe_ports port 21          # ftp
        acl Safe_ports port 443         # https
        acl CONNECT method CONNECT

        # Deny requests to certain unsafe ports
        http_access deny !Safe_ports

        # Deny CONNECT to other than secure SSL ports
        http_access deny CONNECT !SSL_ports

        # Only allow cachemgr access from localhost
        http_access allow localhost manager
        http_access deny manager

        # from where browsing should be allowed
        http_access allow localnet
        http_access allow localhost

        # And finally deny all other access to this proxy
        http_access deny all

        http_port 3128

        coredump_dir /var/spool/squid

* Reiniciamos el servicio y nos dirigimos a nuestro navegador, entraremos en `Preferencias > General > Configuracion de Red` donde manualmente añadiremos la IP de nuestro proxy para que use este por defecto.

![navegador](/proxy/1.png)

* Accedemos a algunas páginas y comprobamos el log de nuestro proxy para ver las peticiones.

        root@proxy:~# cat /var/log/squid/access.log
        1622984095.401     94 172.22.100.1 TCP_TUNNEL/200 5400 CONNECT storage.googleapis.com:443 - HIER_DIRECT/216.58.215.176 -
        1622984095.403     96 172.22.100.1 TCP_TUNNEL/200 5691 CONNECT storage.googleapis.com:443 - HIER_DIRECT/216.58.215.176 -
        1622984095.408    102 172.22.100.1 TCP_TUNNEL/200 5158 CONNECT storage.googleapis.com:443 - HIER_DIRECT/216.58.215.176 -
        1622984095.418    111 172.22.100.1 TCP_TUNNEL/200 6556 CONNECT storage.googleapis.com:443 - HIER_DIRECT/216.58.215.176 -
        1622984095.419    112 172.22.100.1 TCP_TUNNEL/200 7280 CONNECT storage.googleapis.com:443 - HIER_DIRECT/216.58.215.176 -
        1622984095.766     93 172.22.100.1 TCP_TUNNEL/200 4999 CONNECT static.chollometro.com:443 - HIER_DIRECT/104.18.27.49 -
        1622984095.772    105 172.22.100.1 TCP_TUNNEL/200 4251 CONNECT static.chollometro.com:443 - HIER_DIRECT/104.18.27.49 -
        1622984095.772    101 172.22.100.1 TCP_TUNNEL/200 4141 CONNECT static.chollometro.com:443 - HIER_DIRECT/104.18.27.49 -
        1622984095.773    104 172.22.100.1 TCP_TUNNEL/200 12936 CONNECT static.chollometro.com:443 - HIER_DIRECT/104.18.27.49 -
        1622984095.781    110 172.22.100.1 TCP_TUNNEL/200 9371 CONNECT static.chollometro.com:443 - HIER_DIRECT/104.18.27.49 -
        1622984097.532     97 172.22.100.1 TCP_TUNNEL/200 10724 CONNECT images-eu.ssl-images-amazon.com:443 - HIER_DIRECT/151.101.133.16 -
        1622984097.541    106 172.22.100.1 TCP_TUNNEL/200 50467 CONNECT images-eu.ssl-images-amazon.com:443 - HIER_DIRECT/151.101.133.16 -
        1622984097.746     48 172.22.100.1 TCP_TUNNEL/200 17462 CONNECT m.media-amazon.com:443 - HIER_DIRECT/151.101.133.16 -
        1622984097.754     62 172.22.100.1 TCP_TUNNEL/200 8211 CONNECT m.media-amazon.com:443 - HIER_DIRECT/151.101.133.16 -
        1622984097.754     64 172.22.100.1 TCP_TUNNEL/200 8529 CONNECT m.media-amazon.com:443 - HIER_DIRECT/151.101.133.16 -
        1622984097.756     67 172.22.100.1 TCP_TUNNEL/200 7872 CONNECT m.media-amazon.com:443 - HIER_DIRECT/151.101.133.16 -
        1622984102.159    178 172.22.100.1 TCP_TUNNEL/200 6117 CONNECT fls-eu.amazon.es:443 - HIER_DIRECT/54.229.150.234 -
        1622984102.183    149 172.22.100.1 TCP_TUNNEL/200 6116 CONNECT fls-eu.amazon.es:443 - HIER_DIRECT/54.229.150.234 -
        1622984102.191    157 172.22.100.1 TCP_TUNNEL/200 6117 CONNECT fls-eu.amazon.es:443 - HIER_DIRECT/54.229.150.234 -
        1622984102.194    158 172.22.100.1 TCP_TUNNEL/200 6117 CONNECT fls-eu.amazon.es:443 - HIER_DIRECT/54.229.150.234 -
        1622984102.216    178 172.22.100.1 TCP_TUNNEL/200 6118 CONNECT fls-eu.amazon.es:443 - HIER_DIRECT/54.229.150.234 -
        1622984163.405    133 172.22.100.1 TCP_TUNNEL/200 2848 CONNECT eltallerdelbit.com:443 - HIER_DIRECT/104.26.12.37 -
        1622984168.407  65934 172.22.100.1 TCP_TUNNEL/200 8620 CONNECT aax-eu.amazon-adsystem.com:443 - HIER_DIRECT/52.95.118.60 -

* Ahora volveremos a configurar nuestro navegador para que use el proxy de nuestro sistema y modificaremos este proxy desde la configuración de nuestra red.

![sistema](/proxy/2.png)

* Volvemos a acceder a alguna página y miramos el log.

        1622984428.496     73 172.22.100.1 TCP_TUNNEL/200 6122 CONNECT github.githubassets.com:443 - HIER_DIRECT/185.199.109.154 -
        1622984428.498     77 172.22.100.1 TCP_TUNNEL/200 11958 CONNECT github.githubassets.com:443 - HIER_DIRECT/185.199.109.154 -
        1622984428.500     78 172.22.100.1 TCP_TUNNEL/200 49147 CONNECT github.githubassets.com:443 - HIER_DIRECT/185.199.109.154 -
        1622984428.505     84 172.22.100.1 TCP_TUNNEL/200 4132 CONNECT github.githubassets.com:443 - HIER_DIRECT/185.199.109.154 -
        1622984428.510     89 172.22.100.1 TCP_TUNNEL/200 10963 CONNECT github.githubassets.com:443 - HIER_DIRECT/185.199.109.154 -
        1622984428.585     73 172.22.100.1 TCP_TUNNEL/200 5812 CONNECT avatars.githubusercontent.com:443 - HIER_DIRECT/185.199.110.133 -
        1622984428.587     75 172.22.100.1 TCP_TUNNEL/200 6503 CONNECT avatars.githubusercontent.com:443 - HIER_DIRECT/185.199.110.133 -
        1622984429.504     47 172.22.100.1 TCP_MISS/200 915 POST http://ocsp.digicert.com/ - HIER_DIRECT/93.184.220.29 application/ocsp-response
        1622984429.519     40 172.22.100.1 TCP_MISS/200 722 POST http://ocsp.digicert.com/ - HIER_DIRECT/93.184.220.29 application/ocsp-response

* Ahora vamos a configurar una máquina que está conectada a la red interna, lo primero que haremos será establecer el uso del servidor proxy mediante una variable del sistema.

        root@cliente:~# export http_proxy='http://10.0.0.10:3128'

* Vamos a descargar algo para verificar que tenemos salida al exterior.

        root@cliente:~# wget https://estaticos.redsara.es/comunes/autofirma/currentversion/AutoFirma_Linux.zip
        --2021-06-06 14:40:45--  https://estaticos.redsara.es/comunes/autofirma/currentversion/AutoFirma_Linux.zip
        Resolving estaticos.redsara.es (estaticos.redsara.es)... 185.73.172.87
        Connecting to estaticos.redsara.es (estaticos.redsara.es)|185.73.172.87|:443... connected.
        HTTP request sent, awaiting response... 200 OK
        Length: 155509984 (148M) [application/zip]
        Saving to: ‘AutoFirma_Linux.zip’

        AutoFirma_Linux.zip        100%[=====================================>] 148.31M  1.44MB/s    in 2m 2s   

        2021-06-06 14:42:47 (1.22 MB/s) - ‘AutoFirma_Linux.zip’ saved [155509984/155509984]

* Pero no podríamos hacer ping.

        root@cliente:~# ping www.google.es
        PING www.google.es (142.250.184.3) 56(84) bytes of data.
        ^C
        --- www.google.es ping statistics ---
        7 packets transmitted, 0 received, 100% packet loss, time 253ms

* Ahora vamos a hacer una lista negra en el servidor para restringir acceso a algunas páginas. Para ello nos dirigimmos al fichero `/etc/squid/squid.conf` y añadimos lo siguiente.

        acl domain_blacklist dstdomain "/etc/squid/domain_blacklist.txt"

        http_access deny domain_blacklist

* Vamos a denegar algo como amazon y sus subdominios.

        vagrant@proxy:~$ sudo cat /etc/squid/domain_blacklist.txt
        .amazon.com

* Esto es lo que sucede si tratamos de acceder.

![denegado](/proxy/3.png)

* Ahora vamos a configurar lo contrario, una lista blanca, en el fichero squid.conf debemos borrar las líneas que añadimos sobre la lista negra y sustituirlas por estas.

        acl domain_whitelist dstdomain "/etc/squid/domain_whitelist.txt"

        http_access deny !domain_whitelist

* Añadiremos a esta lista blanca google.es y sus subdominios.

        vagrant@proxy:~$ sudo cat /etc/squid/domain_whitelist.txt
        .google.es

* De manera que si accedemos a google.es no tendríamos problemas, pero si con cualquier otro.

![lista](/proxy/4.png)

![blanca](/proxy/5.png)

### Proxy inverso con Doker.

* Instalamos los paquetes necesarios.

        alejandrogv@AlejandroGV:~$ sudo apt install docker.io docker-compose nginx

* Ahora crearemos un fichero `docker-compose.yaml` donde definiremos los contenedores, dos para joomla y otros dos para nextcloud, uno para las aplicaciones y otro para las bases de datos.

        version: '3.1'

        services:

          joomla:
            container_name: joomla
            image: joomla
            restart: always
            environment:
              JOOMLA_DB_HOST: dbjoomla
              JOOMLA_DB_USER: usuario    
              JOOMLA_DB_PASSWORD: admin
              JOOMLA_DB_NAME: bd_joomla
            ports:
              - 8081:80

          dbjoomla:
            container_name: db_joomla
            image: mariadb
            restart: always
            environment:
              MYSQL_DATABASE: bd_joomla
              MYSQL_USER: usuario    
              MYSQL_PASSWORD: admin 
              MYSQL_ROOT_PASSWORD: admin 

          nextcloud:
            container_name: nextcloud
            image: nextcloud
            restart: always
            environment:
              MYSQL_HOST: dbnextcloud
              MYSQL_USER: usuario       
              MYSQL_PASSWORD: admin 
              MYSQL_DATABASE: bd_nextcloud
            ports:
              - 8082:80

          dbnextcloud:
            container_name: db_nextcloud
            image: mariadb
            restart: always
            environment:
              MYSQL_DATABASE: bd_nextcloud
              MYSQL_USER: usuario       
              MYSQL_PASSWORD: admin 
              MYSQL_ROOT_PASSWORD: admin

* Levantamos el escenario.

        alejandrogv@AlejandroGV:~$ sudo docker-compose up -d
        Creating db_nextcloud ... done
        Creating db_joomla    ... done
        Creating joomla       ... done
        Creating nextcloud    ... done

* Vemos que joomla se está sirviendo por el puerto 8081 y nextcloud por el 8082 tal y como definimos el fichero de configuración del escenario.

![joomla](/proxy/6.png)

![nextcloud](/proxy/7.png)

* Ahora crearemos dos virtual hosts en nginx en los que haremos proxy inverso.

#### app1

        server {
                listen 80;
                listen [::]:80;

                index index.html index.htm index.nginx-debian.html;

                server_name www.app1.org;

                location / {
                        proxy_pass http://localhost:8081;
                }
        }

#### app2

        server {
                listen 80;
                listen [::]:80;

                index index.html index.htm index.nginx-debian.html;

                server_name www.app2.org;

                location / {
                        proxy_pass http://localhost:8082;
                }
        }

* Creamos los enlaces simbólicos y reiniciamos el servicio.

        root@AlejandroGV:~# ln -s /etc/nginx/sites-available/app1 /etc/nginx/sites-enabled/
        root@AlejandroGV:~# ln -s /etc/nginx/sites-available/app2 /etc/nginx/sites-enabled/
        root@AlejandroGV:~# systemctl reload nginx

* Si ahora accedemos a app1 y app2 debería aparecer la aplicación joomla y netxcloud.

![joomla](/proxy/8.png)

![nextcloud](/proxy/9.png)

* Vamos a eliminar los virtual host y crear un nuevo que acceda a los dos, tendrá un mismo server name, pero cuando accedamos a www.servidor.org\app1 abrirá joomla y cuando accedamos a www.servidor.org\app2 abrirá nextcloud.

        server {
                listen 80;
                listen [::]:80;
        
                index index.html index.htm index.nginx-debian.html;
        
                server_name www.servidor.org;
        
                location /app1/ {
                        proxy_pass http://localhost:8081/;
                }
        
                location /app2/ {
                        proxy_pass http://localhost:8082/;
                }
        }

* Comprobamos su funcionamiento.

![joomla](/proxy/10.png)

![nextcloud](/proxy/11.png)