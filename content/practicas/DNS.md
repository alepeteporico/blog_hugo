+++
title = "Servidor DNS"
description = ""
tags = [
    "SRI"
]
date = "2021-05-10"
menu = "main"
+++

---

1. En nuestra red local tenemos un servidor Web que sirve dos páginas web: www.iesgn.org, departamentos.iesgn.org

2. Vamos a instalar en nuestra red local un servidor DNS (lo puedes instalar en el mismo equipo que tiene el servidor web)

3. Voy a suponer en este documento que el nombre del servidor DNS va a ser pandora.iesgn.org. El nombre del servidor de tu prácticas será tunombre.iesgn.org.

___

### DNSmasq

#### Instala el servidor dns dnsmasq en pandora.iesgn.org y configúralo para que los clientes puedan conocer los nombres necesarios.

#### Modifica los clientes para que utilicen el nuevo servidor dns. Realiza una consulta a www.iesgn.org, y a www.josedomingo.org. Realiza una prueba de funcionamiento para comprobar que el servidor dnsmasq funciona como cache dns. Muestra el fichero hosts del cliente para demostrar que no estás utilizando resolución estática. Realiza una consulta directa al servidor dnsmasq. ¿Se puede realizar resolución inversa?. Documenta la tarea en redmine.

* Nuestro primer paso será instalar DNSmasq.

        vagrant@dns:~$ sudo apt install dnsmasq

* Después de crear con apache2 los sitios `www.iesgn.org` y  `departamentos.iesgn.org` configuraremos nuestro `/etc/hosts`

        172.22.100.10   www.iesgn.org
        172.22.100.10   departamentos.iesgn.org

* Ahora, después de reiniciar el servicio procederemos a la configuración del cliente y el primer paso será instalar los paquetes necesarios.

        vagrant@cliente:~$ sudo apt install dnsutils

* Configuramos el `/etc/resolv.conf` añadiendo la siguiente línea donde se especifíca que nuestro servidor dns se encuentra en la dirección IP especificada.

        nameserver 172.22.100.10

* Veamos las pruebas de funcionamiento

        vagrant@cliente:~$ dig www.iesgn.org
        
        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> www.iesgn.org
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 5427
        ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
        
        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ;; QUESTION SECTION:
        ;www.iesgn.org.			IN	A
        
        ;; ANSWER SECTION:
        www.iesgn.org.		0	IN	A	172.22.100.10
        
        ;; Query time: 1 msec
        ;; SERVER: 172.22.100.10#53(172.22.100.10)
        ;; WHEN: Tue May 18 08:53:35 UTC 2021
        ;; MSG SIZE  rcvd: 58


        vagrant@cliente:~$ dig departamentos.iesgn.org

        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> departamentos.iesgn.org
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 40894
        ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ;; QUESTION SECTION:
        ;departamentos.iesgn.org.	IN	A

        ;; ANSWER SECTION:
        departamentos.iesgn.org. 0	IN	A	172.22.100.10

        ;; Query time: 0 msec
        ;; SERVER: 172.22.100.10#53(172.22.100.10)
        ;; WHEN: Tue May 18 08:56:35 UTC 2021
        ;; MSG SIZE  rcvd: 68


        vagrant@cliente:~$ dig www.josedomingo.org

        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> www.josedomingo.org
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 4059
        ;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 512
        ;; QUESTION SECTION:
        ;www.josedomingo.org.		IN	A

        ;; ANSWER SECTION:
        www.josedomingo.org.	900	IN	CNAME	endor.josedomingo.org.
        endor.josedomingo.org.	900	IN	A	37.187.119.60

        ;; Query time: 383 msec
        ;; SERVER: 172.22.100.10#53(172.22.100.10)
        ;; WHEN: Tue May 18 08:57:21 UTC 2021
        ;; MSG SIZE  rcvd: 84

* Vamos a hacer una consulta directa a nuestro servidor DNS usando la opción `-x` para hacer una resolución inversa.

        vagrant@cliente:~$ dig -x 172.22.100.10

        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> -x 172.22.100.10
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 56414
        ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ;; QUESTION SECTION:
        ;10.100.22.172.in-addr.arpa.	IN	PTR

        ;; ANSWER SECTION:
        10.100.22.172.in-addr.arpa. 0	IN	PTR	www.iesgn.org.

        ;; Query time: 0 msec
        ;; SERVER: 172.22.100.10#53(172.22.100.10)
        ;; WHEN: Tue May 18 08:59:24 UTC 2021
        ;; MSG SIZE  rcvd: 82

### Bind9

#### Realiza la instalación y configuración del servidor bind9 con las características anteriomente señaladas. Entrega las zonas que has definido. Muestra al profesor su funcionamiento.

#### Realiza las consultas dig/nslookup desde los clientes preguntando por los siguientes: 

1. **Dirección de pandora.iesgn.org, www.iesgn.org, ftp.iesgn.org**
2. **El servidor DNS con autoridad sobre la zona del dominio iesgn.org**
3. **El servidor de correo configurado para iesgn.org**
4. **La dirección IP de www.josedomingo.org**
5. **Una resolución inversa**

* Para empezar instalemos nuestro servidor bind9 en el servidor.

        vagrant@dns:~$ sudo apt install bind9

* Configuraremos el fichero `/etc/bind/named.conf.options` añadiendo las siguientes líneas, estás son opciones que debemos configurar para que nuestro servicio funcione correctamente:

        recursion yes;

        allow-recursion { any; };

        listen-on { any; };

        allow-transfer { none; };

* Y procedemos a configurar el fichero `/etc/bind/named.conf.local` en el que debemos hacer varias cosas, la primera de ellas descomentar esta línea que viene por defecto en el fichero.

        include "/etc/bind/zones.rfc1918";

* Seguidamente deberemos añadir una sección "zone" para cada una de las zonas sobre las que nuestro servidor tendrá autoridad, nosotros configuraremos dos, una zona directa y otra inversa.

        include "/etc/bind/zones.rfc1918";

        zone "iesgn.org" {
                type master;
                file "db.iesgn.org";
        };

        zone "100.22.172.in-addr.arpa" {
                type master;
                file "db.100.22.172";
        };

* Después de definir las zonas en el fichero anterior, debemos definir su contenido  que se guardará en ficheros en `/var/cache/bind`, para que nos sea mas sencillo podríamos usar una plantilla que se encuentra en `/etc/bind/db.empty` y trabajar sobre ella. la primera zona que configuraremos será la directa `db.iesgn.org`.

        $TTL    86400
        @       IN      SOA     alegv.iesgn.org. admin.iesgn.org. (
                                 24367          ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                  86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      alegv.iesgn.org.
        @       IN      MX 10   correo.iesgn.org.

        $ORIGIN iesgn.org.

        alvaro  IN      A       172.22.100.10
        correo  IN      A       172.22.100.200
        ftp     IN      A       172.22.100.201
        www     IN      CNAME   alegv
        departamentos   IN      CNAME   alegv

* Las IP de los servidores de correo y ftp no existen, están puestas en el caso de que existieran y estuvieran configuradas estas máquinas para ver la configuración.

* Veamos la resolución inversa en el fichero que crearemos en `/var/cache/bind` y deberá llamarse `db.100.22.172`.

        $TTL    86400
        @       IN      SOA     alegv.iesgn.org. admin.iesgn.org. (
                                 24367          ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                  86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      alegv.iesgn.org.

        $ORIGIN 100.22.172.in-addr.arpa.

        10      IN      PTR     alegv.iesgn.org.
        200     IN      PTR     correo.iesgn.org.
        201     IN      PTR     ftp.iesgn.org.

* Podemos ejecutar un comando que nos avisaría si hubiera algunos problema al ejecutarlo, si no dice nada entonces en principio no hay ningún problema en la configuración.

        vagrant@alegv:~$ sudo named-checkconf

* Vamos a hacer las comprobaciones necesarias desde nuestro cliente.

        vagrant@cliente:~$ dig +short alegv.iesgn.org
        172.22.100.10


        vagrant@cliente:~$ dig www.iesgn.org

        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> www.iesgn.org
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 29477
        ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 1

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ; COOKIE: ff1c4ccbff950cdc8be14b1460a3aef0f719f12da0926301 (good)
        ;; QUESTION SECTION:
        ;www.iesgn.org.			IN	A

        ;; ANSWER SECTION:
        www.iesgn.org.		86400	IN	CNAME	alegv.iesgn.org.
        alegv.iesgn.org.	86400	IN	A	172.22.100.10

        ;; AUTHORITY SECTION:
        iesgn.org.		86400	IN	NS	alegv.iesgn.org.

        ;; Query time: 1 msec
        ;; SERVER: 172.22.100.10#53(172.22.100.10)
        ;; WHEN: Tue May 18 12:11:28 UTC 2021
        ;; MSG SIZE  rcvd: 120


        vagrant@cliente:~$ dig +short ftp.iesgn.org
        172.22.100.201


        vagrant@cliente:~$ dig ns iesgn.org

        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> ns iesgn.org
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 25145
        ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ; COOKIE: 6f922539f9822eb858d4916e60a3af4dbdf6b0465ccaaf71 (good)
        ;; QUESTION SECTION:
        ;iesgn.org.			IN	NS

        ;; ANSWER SECTION:
        iesgn.org.		86400	IN	NS	alegv.iesgn.org.

        ;; ADDITIONAL SECTION:
        alegv.iesgn.org.	86400	IN	A	172.22.100.10

        ;; Query time: 1 msec
        ;; SERVER: 172.22.100.10#53(172.22.100.10)
        ;; WHEN: Tue May 18 12:13:01 UTC 2021
        ;; MSG SIZE  rcvd: 102


        vagrant@cliente:~$ dig mx iesgn.org

        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> mx iesgn.org
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 25542
        ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 3

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ; COOKIE: f487747bcbf1a88b61922ff160a3af6971cd0c8f7d512fd1 (good)
        ;; QUESTION SECTION:
        ;iesgn.org.			IN	MX

        ;; ANSWER SECTION:
        iesgn.org.		86400	IN	MX	10 correo.iesgn.org.

        ;; AUTHORITY SECTION:
        iesgn.org.		86400	IN	NS	alegv.iesgn.org.

        ;; ADDITIONAL SECTION:
        correo.iesgn.org.	86400	IN	A	172.22.100.200
        alegv.iesgn.org.	86400	IN	A	172.22.100.10

        ;; Query time: 0 msec
        ;; SERVER: 172.22.100.10#53(172.22.100.10)
        ;; WHEN: Tue May 18 12:13:29 UTC 2021
        ;; MSG SIZE  rcvd: 141


        vagrant@cliente:~$ dig -x 172.22.100.10

        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> -x 172.22.100.10
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 16433
        ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ; COOKIE: 7d21fc7c1769da8cb69f60e260a3af82e1cedbfe61b23877 (good)
        ;; QUESTION SECTION:
        ;10.100.22.172.in-addr.arpa.	IN	PTR

        ;; ANSWER SECTION:
        10.100.22.172.in-addr.arpa. 86400 IN	PTR	alegv.iesgn.org.

        ;; AUTHORITY SECTION:
        100.22.172.in-addr.arpa. 86400	IN	NS	alegv.iesgn.org.

        ;; ADDITIONAL SECTION:
        alegv.iesgn.org.	86400	IN	A	172.22.100.10

        ;; Query time: 0 msec
        ;; SERVER: 172.22.100.10#53(172.22.100.10)
        ;; WHEN: Tue May 18 12:13:54 UTC 2021
        ;; MSG SIZE  rcvd: 142


        vagrant@cliente:~$ dig www.josedomingo.org

        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> www.josedomingo.org
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 46921
        ;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 5, ADDITIONAL: 2

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ; COOKIE: 5d3a7d853ce5f80e2413a54860a3af96f28515e280b44329 (good)
        ;; QUESTION SECTION:
        ;www.josedomingo.org.		IN	A

        ;; ANSWER SECTION:
        www.josedomingo.org.	642	IN	CNAME	endor.josedomingo.org.
        endor.josedomingo.org.	642	IN	A	37.187.119.60

        ;; AUTHORITY SECTION:
        josedomingo.org.	86141	IN	NS	ns3.cdmon.net.
        josedomingo.org.	86141	IN	NS	ns4.cdmondns-01.org.
        josedomingo.org.	86141	IN	NS	ns5.cdmondns-01.com.
        josedomingo.org.	86141	IN	NS	ns1.cdmon.net.
        josedomingo.org.	86141	IN	NS	ns2.cdmon.net.

        ;; ADDITIONAL SECTION:
        ns4.cdmondns-01.org.	86141	IN	A	52.58.66.183

        ;; Query time: 0 msec
        ;; SERVER: 172.22.100.10#53(172.22.100.10)
        ;; WHEN: Tue May 18 12:14:14 UTC 2021
        ;; MSG SIZE  rcvd: 254

### DNS esclavo

* En nuestro `/etc/bind/named.conf.options` del nuestro servidor maestro añadimos la siguientes líneas apuntando al que será el DNS secundario.

                allow-transfer { 172.22.100.15; };
                notify yes;

* Y en nuestro ficheros `db.iesgn.org` y `db.100.22.172` añadimos también el DNS secundario.

        secundario      IN      A       172.22.100.15

* En la máquina que servira como DNS secundario instalaremos bind9.

        vagrant@dnsesclavo:~$ sudo apt install bind9

* Añadimos esto a `named.conf.options`

        allow-transfer { none; };

* Y definimos las zonas que están en el servidor primario en el fichero `named.conf.local`

        zone "iesgn.org" {
                type slave;
                file "db.iesgn.org";
                masters { 172.22.100.10; };
        };
        
        zone "100.22.172.in-addr.arpa" {
                type slave;
                file "db.100.22.172";
                masters { 172.22.100.10; };
        };

* Configuraremos el cliente para que use los dos servidores modificando su `/etc/resolv.conf`

        nameserver 172.22.100.10
        nameserver 172.22.100.15

* Comprobamos que podemos hacer una consulta a traves del DNS secundario.

        vagrant@cliente:~$ dig @172.22.100.15 ftp.iesgn.org

        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> @172.22.100.15 ftp.iesgn.org
        ; (1 server found)
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 56695
        ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ; COOKIE: 6ec8f9bfe693967950f7ab1d60bdf891fda2bd761dee9b9b (good)
        ;; QUESTION SECTION:
        ;ftp.iesgn.org.			IN	A

        ;; ANSWER SECTION:
        ftp.iesgn.org.		86400	IN	A	172.22.100.201

        ;; AUTHORITY SECTION:
        iesgn.org.		86400	IN	NS	secundario.iesgn.org.
        iesgn.org.		86400	IN	NS	alegv.iesgn.org.

        ;; ADDITIONAL SECTION:
        alegv.iesgn.org.	86400	IN	A	172.22.100.10
        secundario.iesgn.org.	86400	IN	A	172.22.100.15

        ;; Query time: 0 msec
        ;; SERVER: 172.22.100.15#53(172.22.100.15)
        ;; WHEN: Mon Jun 07 10:44:33 UTC 2021
        ;; MSG SIZE  rcvd: 163

-------------------------------------------------------------------

### Delegación de dominios.

#### Realiza la instalación y configuración del nuevo servidor dns con las características anteriormente señaladas. Muestra el resultado al profesor.

#### Realiza las consultas dig/neslookup desde los clientes preguntando por los siguientes:

1. **Dirección de www.informatica.iesgn.org, ftp.informatica.iesgn.org**
2. **El servidor DNS que tiene configurado la zona del dominio informatica.iesgn.org. ¿Es el mismo que el servidor DNS con autoridad para la zona iesgn.org?**
3. **El servidor de correo configurado para informatica.iesgn.org**

* Configuraremos en nuestro servidor maestro el archivo `/etc/bind/named.conf.local` añadiendo las siguiente línea en las dos zonas que ya tenemos creadas.

        allow-transfer { 172.22.100.15; };
        notify yes;

* Añadimos nuestro DNS secundario en los archivos `db.iesgn.org` y `db.100.22.172`

#### iesgn

        $TTL    86400
        @       IN      SOA     alegv.iesgn.org. admin.iesgn.org. (
                                 1              ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                  86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      alegv.iesgn.org.
        @       IN      MX 10   correo.iesgn.org.
        @       IN      NS      secundario.iesgn.org.

        $ORIGIN iesgn.org.

        alegv   IN      A       172.22.100.10
        correo  IN      A       172.22.100.200
        ftp     IN      A       172.22.100.201
        www     IN      CNAME   alegv
        departamentos   IN      CNAME   alegv
        secundario      IN      A       172.22.100.15

#### 100.22.172

        $TTL    86400
        @       IN      SOA     alegv.iesgn.org. alegv.iesgn.org. (
                                 1526           ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                  86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      alegv.iesgn.org.
        @       IN      NS      secundario.iesgn.org.

        $ORIGIN 100.22.172.in-addr.arpa.

        10      IN      PTR     alegv.iesgn.org.
        200     IN      PTR     correo.iesgn.org.
        201     IN      PTR     ftp.iesgn.org.
        15      IN      PTR     secundario.iesgn.org.

* Vamos a añadir un nuevo registro. Para que surta efecto en el dns secundario deberemos cambiar también el valor del serial.

        algo    IN      A       172.22.100.33

* Comprobamos que funciona después de apagar el dns primario.

        vagrant@cliente:~$ dig algo.iesgn.org
        
        ; <<>> DiG 9.11.5-P4-5.1+deb10u5-Debian <<>> algo.iesgn.org
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 58246
        ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3
        
        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ; COOKIE: f7a45f64a6c02d8cfa88cdb160c9da90526d10b9630c1119 (good)
        ;; QUESTION SECTION:
        ;algo.iesgn.org.			IN	A
        
        ;; ANSWER SECTION:
        algo.iesgn.org.		86400	IN	A	172.22.100.33
        
        ;; AUTHORITY SECTION:
        iesgn.org.		86400	IN	NS	secundario.iesgn.org.
        iesgn.org.		86400	IN	NS	alegv.iesgn.org.
        
        ;; ADDITIONAL SECTION:
        alegv.iesgn.org.	86400	IN	A	172.22.100.10
        secundario.iesgn.org.	86400	IN	A	172.22.100.15
        
        ;; Query time: 0 msec
        ;; SERVER: 172.22.100.15#53(172.22.100.15)
        ;; WHEN: Wed Jun 16 11:03:44 UTC 2021
        ;; MSG SIZE  rcvd: 164

* Reiniciamos el servicio y nos dirijimos a nuestro DNS esclavo, después de instalar el paquete bind9 configuraremos el archivo `/etc/bind/named.conf.options` tal como hicimos en nuestro servidor maestro anteriormente añadiendo estas líneas.

        recursion yes;

        allow-recursion { any; };

        listen-on { any; };

        allow-transfer { 172.22.100.15; };
        notify yes;

* Ahora editaremos el fichero `/etc/bind/named.conf.local` dejandolo de la siguiente manera.

        include "/etc/bind/zones.rfc1918";

        zone "iesgn.org" {
                type slave;
                file "db.iesgn.org";
                masters { 172.22.100.10; };
        };

        zone "100.22.172.in-addr.arpa" {
                type slave;
                file "db.200.22.172";
                masters { 172.22.100.10; };
        };

* Añadiremos un nuevo registro ORIGIN para realizar la delegación de dominio.

        $ORIGIN delegacion.iesgn.org.

        @       IN      NS      secundario
        secundario        IN      A       172.22.100.15

* Vamos a apagar el DNS primario y a preguntar sobre la nueva zona desde el cliente, comprobando que se ha realizado la delegación 

        $ORIGIN delegacion.iesgn.org.

        @       IN      NS      secundario
        secundario        IN      A       172.22.100.15

* Nos dirigimos al DNS secundario y añadimos una nueva zona a nuestro named.conf.local.

        zone "delegacion.iesgn.org" {
                type master;
                file "db.delegacion.iesgn.org";
        };

* Crearemos el fichero db.delegacion.iesgn.org

        $TTL    86400
        @       IN      SOA     delegacion.delegacion.iesgn.org. admin.delegacion.iesgn.org. (
                               20120401         ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                  86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      secundario.delegacion.iesgn.org.
        @       IN      MX      10      correo.delegacion.iesgn.org.

        $ORIGIN delegacion.iesgn.org.

        secundario        IN      A       172.22.100.15
        correo  IN      A       172.22.100.200
        www     IN      A       172.22.100.201
        ftp     IN      CNAME   secundario

* 