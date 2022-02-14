+++
title = "DNS, servidor web y base de datos"
description = ""
tags = [
    "SRI"
]
date = "2021-03-16"
menu = "main"
+++


### Servidor DNS

*El servidor DNS estará instalado en freston, por ello instalaremos bind en esta máquina

        root@apolo:~# apt install bind9

*Configuramos el fichero "/etc/bind/named.conf.options" y añadimos las siguientes líneas:

~~~
        listen-on { any; };
        allow-transfer { none; };
        recursion yes;
        allow-recursion { any; };
~~~

*Configuramos el DNS local, la DMZ y externa en el fichero de configuración /etc/bind/named.conf.local:

~~~
view interna {
	match-clients { 10.0.1.0/24; 127.0.0.1; };
	allow-recursion { any; };

	zone "alegv.gonzalonazareno.org" {
		type master;
		file "db.alegv.interna";
	};

        zone "1.0.10.in-addr-arpa" { 
                type master;
                file "db.1.0.10";
        };

        zone "16.172.in-addr.arpa" { 
                type master;
                file "db.16.172";
        };

	include "/etc/bind/zones.rfc1918";
	include "/etc/bind/named.conf.default-zones";
};

view dmz {
        match-clients { 172.16.0.0/16; };

        zone "alegv.gonzalonazareno.org" {
                type master;
                file "db.alegv.dmz";
        };

        zone "1.0.10.in-addr-arpa" {
                type master;
                file "db.1.0.10";
        };

        zone "16.172.in-addr.arpa" {
                type master;
                file "db.16.172";
        };

        include "/etc/bind/zones.rfc1918";
        include "/etc/bind/named.conf.default-zones";
};

view externa {
	match-clients { 172.22.0.0/16; 192.168.202.2/32; };
	
	zone "alegv.gonzalonazareno.org" {
		type master;
		file "db.alegv.externa";
	};

        include "/etc/bind/zones.rfc1918";
        include "/etc/bind/named.conf.default-zones";
};
~~~

* Y en el fichero "/etc/bind/named.conf" debemos comentar esta línea:

~~~
//include "/etc/bind/named.conf.default-zones";
~~~

**Crearemos los archivos db, lo hacemos en la carpeta "/var/cache/bind/"**

### db.alegv.interna

~~~
$TTL    86400
@       IN      SOA     apolo.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      apolo.alegv.gonzalonazareno.org.

$ORIGIN alegv.gonzalonazareno.org.

zeus	IN      A       10.0.1.1
ares	IN      A       10.0.1.101
apolo	IN      A       10.0.1.102
hera	IN      A       172.16.0.200
www     IN      CNAME   hera
bd      IN      CNAME   ares
~~~

### db.alegv.dmz

~~~
$TTL	86400
@       IN      SOA     apolo.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      apolo.alegv.gonzalonazareno.org.

$ORIGIN alegv.gonzalonazareno.org.

zeus    IN      A       172.16.0.1
ares    IN      A       10.0.1.101
apolo   IN      A       10.0.1.102
hera    IN      A       172.16.0.200
www     IN      CNAME   hera   
bd      IN      CNAME   ares
~~~

### db.alegv.externa

~~~
$TTL    86400
@       IN      SOA     zeus.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      zeus.alegv.gonzalonazareno.org.
@	IN	MX 10	zeus.alegv.gonzalonazareno.org.

$ORIGIN alegv.gonzalonazareno.org.

zeus	IN	A	172.22.3.191
www     IN      CNAME   zeus   
bd      IN      CNAME   zeus
~~~

**Ahora crearemos los archivos de las resoluciones inversas en la misma ruta**

### db.1.0.10

~~~
$TTL    86400
@       IN      SOA     apolo.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      apolo.alegv.gonzalonazareno.org.

$ORIGIN 1.0.10.in-addr.arpa.

1	IN	PTR	zeus.alegv.gonzalonazareno.org.
101	IN	PTR	ares.alegv.gonzalonazareno.org.
102	IN	PTR	apolo.alegv.gonzalonazareno.org.
~~~

### db.16.172

~~~
$TTL    86400
@       IN      SOA     apolo.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      apolo.alegv.gonzalonazareno.org.

$ORIGIN 16.172.in-addr.arpa.

0.200	IN	PTR	hera.alegv.gonzalonazareno.org.
0.1	IN	PTR	zeus.alegv.gonzalonazareno.org.
~~~

* Si quisieramos asegurarnos de que no tenemos ningún error de sintáxis podemos usar esto:

~~~
root@freston:/var/cache/bind# named-checkconf
~~~

* IPV6 da conflictos, así que podemos deshabilitarlo en el fichero "/etc/default/bind9"

~~~
# run resolvconf?
RESOLVCONF=yes

# startup options for the server
OPTIONS="-4 -u bind"
~~~

* Reiniciamos el servicio de DNS

~~~
debian@apolo:~$ sudo systemctl restart bind9

debian@apolo:~$ sudo systemctl status bind9
* named.service - BIND Domain Name Server
     Loaded: loaded (/lib/systemd/system/named.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2022-02-02 09:55:21 CET; 1min 23s ago
       Docs: man:named(8)
   Main PID: 1775 (named)
      Tasks: 5 (limit: 529)
     Memory: 18.7M
        CPU: 98ms
     CGroup: /system.slice/named.service
             `-1775 /usr/sbin/named -f -u bind

Feb 02 09:55:21 apolo named[1775]: zone 168.192.in-addr.arpa/IN/externa: loaded serial 1
Feb 02 09:55:21 apolo named[1775]: zone alegv.gonzalonazareno.org/IN/externa: loaded serial 1
Feb 02 09:55:21 apolo named[1775]: all zones loaded
Feb 02 09:55:21 apolo named[1775]: running
Feb 02 09:55:21 apolo named[1775]: managed-keys-zone/externa: Key 20326 for zone . is now trusted (accep>
Feb 02 09:55:21 apolo named[1775]: resolver priming query complete
Feb 02 09:55:21 apolo named[1775]: managed-keys-zone/dmz: Key 20326 for zone . is now trusted (acceptanc>
Feb 02 09:55:22 apolo named[1775]: resolver priming query complete
Feb 02 09:55:22 apolo named[1775]: managed-keys-zone/interna: Key 20326 for zone . is now trusted (accep>
Feb 02 09:55:22 apolo named[1775]: resolver priming query complete
~~~

* Vamos a hacer las comprobaciones necesarias en cada máquina:

1. El servidor DNS con autoridad sobre la zona del dominio tu_nombre.gonzalonazareno.org.

### Interna

~~~
debian@zeus:~$ dig alegv.gonzalonazareno.org

; <<>> DiG 9.16.22-Debian <<>> alegv.gonzalonazareno.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 26327
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 673e0e7f90f0376a0100000061fa47a7b129b2cb088a4078 (good)
;; QUESTION SECTION:
;alegv.gonzalonazareno.org.	IN	A

;; AUTHORITY SECTION:
alegv.gonzalonazareno.org. 86400 IN	SOA	apolo.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. 1 604800 86400 2419200 86400

;; Query time: 0 msec
;; SERVER: 10.0.1.102#53(10.0.1.102)
;; WHEN: Wed Feb 02 09:58:15 CET 2022
;; MSG SIZE  rcvd: 130
~~~

### Externa

~~~
alejandrogv@AlejandroGV:~$ dig alegv.gonzalonazareno.org

; <<>> DiG 9.16.22-Debian <<>> alegv.gonzalonazareno.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12856
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: d14809270130ee359e88c61961f8ef40775f5cc6025b334e (good)
;; QUESTION SECTION:
;alegv.gonzalonazareno.org.	IN	A

;; AUTHORITY SECTION:
alegv.gonzalonazareno.org. 10748 IN	SOA	zeus.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. 1 604800 86400 2419200 86400

;; Query time: 0 msec
;; SERVER: 192.168.202.2#53(192.168.202.2)
;; WHEN: Tue Feb 01 09:28:48 CET 2022
;; MSG SIZE  rcvd: 129
~~~

2. La dirección IP de zeus.

### Interna

~~~
[hera@hera ~]$ dig +short zeus.alegv.gonzalonazareno.org
172.16.0.1

debian@apolo:~$ dig +short zeus.alegv.gonzalonazareno.org
10.0.1.1
~~~

### Externa

~~~
alejandrogv@AlejandroGV:~$ dig +short zeus.alegv.gonzalonazareno.org
172.22.3.191
~~~

3. Una resolución de www.

### Interna

~~~
debian@apolo:~$ dig +short www.alegv.gonzalonazareno.org
hera.alegv.gonzalonazareno.org.
172.16.0.200
~~~

### Externa

~~~
alejandrogv@AlejandroGV:~$ dig +short www.alegv.gonzalonazareno.org
zeus.alegv.gonzalonazareno.org.
172.22.3.191
~~~

4. Una resolución de bd.

### Interna

~~~
debian@apolo:~$ dig +short bd.alegv.gonzalonazareno.org
ares.alegv.gonzalonazareno.org.
10.0.1.101
~~~

### Externa

~~~
alejandrogv@AlejandroGV:~$ dig +short bd.alegv.gonzalonazareno.org
zeus.alegv.gonzalonazareno.org.
172.22.3.191
~~~

5. Un resolución inversa de IP fija en cada una de las redes.

~~~
debian@zeus:~$ dig +short -x 10.0.1.101
ares.alegv.gonzalonazareno.org.

debian@zeus:~$ dig +short -x 172.16.0.200
hera.alegv.gonzalonazareno.org.
~~~

### Dulcinea

        debian@dulcinea:~$ dig +short @10.0.1.9 dulcinea.alegv.gonzalonazareno.org
        10.0.1.8
        debian@dulcinea:~$ dig +short @10.0.1.9 freston.alegv.gonzalonazareno.org
        10.0.1.9
        debian@dulcinea:~$ dig +short @10.0.1.9 quijote.alegv.gonzalonazareno.org
        10.0.2.5
        debian@dulcinea:~$ dig +short @10.0.1.9 sancho.alegv.gonzalonazareno.org
        10.0.1.3

        debian@dulcinea:~$ dig +short @10.0.1.9 bd.alegv.gonzalonazareno.org
        sancho.alegv.gonzalonazareno.org.
        10.0.1.3
        debian@dulcinea:~$ dig +short @10.0.1.9 www.alegv.gonzalonazareno.org
        quijote.alegv.gonzalonazareno.org.
        10.0.2.2


### Quijote

        [centos@quijote ~]$ dig +short @10.0.1.9 -x 10.0.2.5
        quijote.2.0.10.in-addr.arpa.
        [centos@quijote ~]$ dig +short @10.0.1.9 -x 10.0.2.10
        dulcinea.2.0.10.in-addr.arpa.

### Sancho

        ubuntu@sancho:~$ dig +short @10.0.1.9 dulcinea.alegv.gonzalonazareno.org
        10.0.1.8
        ubuntu@sancho:~$ dig +short @10.0.1.9 freston.alegv.gonzalonazareno.org
        10.0.1.9

### Freston

        debian@freston:~$ dig +short @localhost -x 10.0.1.3
        sancho.1.0.10.in-addr.arpa.

        debian@freston:~$ dig +short @localhost -x 10.0.1.8
        dulcinea.1.0.10.in-addr.arpa.

### Desde fuera:

~~~




alejandrogv@AlejandroGV:~$ dig +short www.alegv.gonzalonazareno.org
zeus.alegv.gonzalonazareno.org.
172.22.3.191
~~~

### Servidor web

**Tenemos el servidor DNS, continuemos con el servidor web, este servidor estará situado en Quijote, será un servidor apache capaz de ejecutar php. Lo primero que deberemos hacer es instalar el servidor apache y php (el paquete de apache en CentOS se llama httpd)**

        [centos@quijote ~]$ sudo dnf install httpd php php-fpm

**Tenemos que iniciar y habilitar los servicios httpd y php**

        [centos@quijote ~]$ sudo systemctl start php-fpm httpd
        [centos@quijote ~]$ sudo systemctl enable php-fpm httpd
        Created symlink /etc/systemd/system/multi-user.target.wants/php-fpm.service → /usr/lib/systemd/system/php-fpm.service.
        Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.

**Para que podamos acceder debemos habilitar en el firewall los puertos 443, 80 y 53**

        [centos@quijote ~]$ sudo firewall-cmd --permanent --add-port=443/tcp
        success
        [centos@quijote ~]$ sudo firewall-cmd --permanent --add-port=80/tcp
        success
        [centos@quijote ~]$ sudo firewall-cmd --permanent --add-port=53/udp
        success

**Para guardarlas debemos hacer un reload y comprobamos las reglas que tenemos:**

        [centos@quijote ~]$ sudo firewall-cmd --reload
        success
        [centos@quijote ~]$ sudo firewall-cmd --list-all
        public (active)
          target: default
          icmp-block-inversion: no
          interfaces: eth0
          sources: 
          services: dhcpv6-client ssh
          ports: 443/tcp 80/tcp 53/udp
          protocols: 
          masquerade: no
          forward-ports: 
          source-ports: 
          icmp-blocks: 
          rich rules:

**En CentOS los directorios sites-avaiable y sites-enabled no se crean por defecto, los crearemos nosotros:**

        [centos@quijote ~]$ sudo mkdir /etc/httpd/sites-enabled /etc/httpd/sites-available

**Ahora entraremos al fichero de configuración "/etc/httpd/conf/httpd.conf" para añadir sites-avaiable como nueva ruta comentando la última línea y añadiendo otra**

        #IncludeOptional conf.d/*.conf
        IncludeOptional	sites-enabled/*.conf

**Directamente pasaremos a la configuración de un virtualhost**

        [centos@quijote ~]$ cat /etc/httpd/sites-available/pagina.conf
        <VirtualHost *:80>
            ServerName www.alegv.gonzalonazareno.org
            DocumentRoot /var/www/alegv

            <Directory /var/www/alegv/>
                Options FollowSymLinks
                AllowOverride All
                Order deny,allow
                Allow from all

                <FilesMatch "\.php">
                        SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost"
                </FilesMatch>

            </Directory>

            ErrorLog /var/www/alegv/log/error.log
            CustomLog /var/www/alegv/log/requests.log combined
        </VirtualHost>

**Creamos el vínculo en sites-enabled y las carpetas necesarias en "/var/www/"**

        [centos@quijote sites-available]$ sudo ln -s pagina.conf ../sites-enabled/
        [centos@quijote ~]$ sudo mkdir -p /var/www/alegv/log

**Selinux nos dará problemas con los nuevos directorios, por ello debemos ejecutar los siguientes comandos y reiniciar el servicio httpd**

        [centos@quijote ~]$ sudo semanage fcontext -a -t httpd_log_t "/var/www/alegv/log(/.*)?"
        [root@quijote ~]# sudo restorecon -R -v /var/www/alegv/log
        [centos@quijote sites-available]$ sudo setsebool -P httpd_unified 1

        [centos@quijote sites-available]$ sudo systemctl restart httpd

**Creamos el fichero info.php**

        [centos@quijote ~]$ cat /var/www/alegv/info.php 
        <?php phpinfo(); ?>

**Comprobemos que funciona**

![info](/dns_web_bbdd/1.png)

### Servidor Base de datos.

**Usaremos el gestor mariadb**

        ubuntu@sancho:~$ sudo apt install mariadb-server

**Y una vez instalado debemos configurarlo para permitir el uso de usuarios remoto accediendo al fichero `/etc/mysql/mariadb.conf.d/50-server.cnf` y modificando la línea `bind-address` tal como aparece a continuación**

        bind-address            = 0.0.0.0

**Ahora vamos a entrar y crear un usuario que usaremos remotamente.**

        ubuntu@sancho:~$ sudo mysql -u root -p

        MariaDB [(none)]> CREATE USER 'ale'@'10.0.2.5' IDENTIFIED BY 'ale';
        Query OK, 0 rows affected (0.009 sec)

**Crearemos una base de datos y daremos a nuestro usuario remoto privilegios sobre ella**

        MariaDB [(none)]> CREATE DATABASE prueba;
        Query OK, 1 row affected (0.010 sec)

        MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'ale'@'10.0.2.5'
            -> ;
        Query OK, 0 rows affected (0.001 sec)

**Ahora vayamos a centos, y lo primero que haremos será instalar el cliente de mariadb**

        [centos@quijote ~]$ sudo dnf install mariadb

**Y procedemos a acceder al servidor mariadb con las credenciales que usamos anteriormente**

        [root@quijote ~]# mysql -u ale -p -h bd.alegv.gonzalonazareno.org
        Enter password: 
        Welcome to the MariaDB monitor.  Commands end with ; or \g.
        Your MariaDB connection id is 37
        Server version: 10.3.29-MariaDB-0ubuntu0.20.04.1 Ubuntu 20.04
        
        Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        MariaDB [(none)]>

**Vamos a comprobar que funciona simplemente listando las bases de datos que tenemos**

        MariaDB [(none)]> SHOW DATABASES;
        +--------------------+
        | Database           |
        +--------------------+
        | information_schema |
        | mysql              |
        | performance_schema |
        | prueba             |
        +--------------------+
        4 rows in set (0.034 sec)