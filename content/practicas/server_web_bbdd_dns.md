+++
title = "DNS, servidor web y base de datos"
description = ""
tags = [
    "SRI"
]
date = "2021-12-10"
menu = "main"
+++


### Servidor DNS

* Configuramos el fichero "/etc/bind/named.conf.options" y añadimos las siguientes líneas:

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

	zone "alexgv.gonzalonazareno.org" {
		type master;
		file "db.alexgv.interna";
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

        zone "alexgv.gonzalonazareno.org" {
                type master;
                file "db.alexgv.dmz";
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
	
	zone "alexgv.gonzalonazareno.org" {
		type master;
		file "db.alexgv.externa";
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

### db.alexgv.interna

~~~
$TTL    86400
@       IN      SOA     apolo.alexgv.gonzalonazareno.org. admin.alexgv.gonzalonazareno.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      apolo.alexgv.gonzalonazareno.org.

$ORIGIN alexgv.gonzalonazareno.org.

zeus	IN      A       10.0.1.1
ares	IN      A       10.0.1.101
apolo	IN      A       10.0.1.102
hera	IN      A       172.16.0.200
www     IN      CNAME   hera
bd      IN      CNAME   ares
~~~

### db.alexgv.dmz

~~~
$TTL	86400
@       IN      SOA     apolo.alexgv.gonzalonazareno.org. admin.alexgv.gonzalonazareno.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      apolo.alexgv.gonzalonazareno.org.

$ORIGIN alexgv.gonzalonazareno.org.

zeus    IN      A       172.16.0.1
ares    IN      A       10.0.1.101
apolo   IN      A       10.0.1.102
hera    IN      A       172.16.0.200
www     IN      CNAME   hera   
bd      IN      CNAME   ares
~~~

### db.alexgv.externa

~~~
$TTL    86400
@       IN      SOA     zeus.alexgv.gonzalonazareno.org. admin.alexgv.gonzalonazareno.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      zeus.alexgv.gonzalonazareno.org.
@	IN	MX 10	zeus.alexgv.gonzalonazareno.org.

$ORIGIN alexgv.gonzalonazareno.org.

zeus	IN	A	172.22.0.169
www     IN      CNAME   zeus   
bd      IN      CNAME   zeus
~~~

**Ahora crearemos los archivos de las resoluciones inversas en la misma ruta**

### db.1.0.10

~~~
$TTL    86400
@       IN      SOA     apolo.alexgv.gonzalonazareno.org. admin.alexgv.gonzalonazareno.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      apolo.alexgv.gonzalonazareno.org.

$ORIGIN 1.0.10.in-addr.arpa.

1	IN	PTR	zeus.alexgv.gonzalonazareno.org.
101	IN	PTR	ares.alexgv.gonzalonazareno.org.
102	IN	PTR	apolo.alexgv.gonzalonazareno.org.
~~~

### db.16.172

~~~
$TTL    86400
@       IN      SOA     apolo.alexgv.gonzalonazareno.org. admin.alexgv.gonzalonazareno.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      apolo.alexgv.gonzalonazareno.org.

$ORIGIN 16.172.in-addr.arpa.

0.200	IN	PTR	hera.alexgv.gonzalonazareno.org.
0.1	IN	PTR	zeus.alexgv.gonzalonazareno.org.
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
Feb 02 09:55:21 apolo named[1775]: zone alexgv.gonzalonazareno.org/IN/externa: loaded serial 1
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
debian@zeus:~$ dig alexgv.gonzalonazareno.org

; <<>> DiG 9.16.22-Debian <<>> alexgv.gonzalonazareno.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 26327
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 673e0e7f90f0376a0100000061fa47a7b129b2cb088a4078 (good)
;; QUESTION SECTION:
;alexgv.gonzalonazareno.org.	IN	A

;; AUTHORITY SECTION:
alexgv.gonzalonazareno.org. 86400 IN	SOA	apolo.alexgv.gonzalonazareno.org. admin.alexgv.gonzalonazareno.org. 1 604800 86400 2419200 86400

;; Query time: 0 msec
;; SERVER: 10.0.1.102#53(10.0.1.102)
;; WHEN: Wed Feb 02 09:58:15 CET 2022
;; MSG SIZE  rcvd: 130
~~~

### Externa

~~~
alejandrogv@AlejandroGV:~$ dig @172.22.0.169 alexgv.gonzalonazareno.org

; <<>> DiG 9.16.27-Debian <<>> @172.22.0.169 alexgv.gonzalonazareno.org
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 30846
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 2a3b27dcd4272d99010000006272345416d34b06d6eea5e3 (good)
;; QUESTION SECTION:
;alexgv.gonzalonazareno.org.	IN	A

;; AUTHORITY SECTION:
alexgv.gonzalonazareno.org. 86400 IN	SOA	zeus.alexgv.gonzalonazareno.org. admin.alexgv.gonzalonazareno.org. 1 604800 86400 2419200 86400

;; Query time: 0 msec
;; SERVER: 172.22.0.169#53(172.22.0.169)
;; WHEN: Wed May 04 10:07:48 CEST 2022
;; MSG SIZE  rcvd: 130
~~~

2. La dirección IP de zeus.

### Interna

~~~
[usuario@hera ~]$ dig +short zeus.alexgv.gonzalonazareno.org
172.16.0.1

usuario@apolo:~$ dig +short zeus.alexgv.gonzalonazareno.org
10.0.1.1
~~~

### Externa

~~~
alejandrogv@AlejandroGV:~$ dig +short zeus.alexgv.gonzalonazareno.org
172.22.0.169
~~~

3. Una resolución de www.

### Interna

~~~
usuario@ares:~$ dig +short www.alexgv.gonzalonazareno.org
hera.alexgv.gonzalonazareno.org.
172.16.0.200
~~~

### Externa

~~~
alejandrogv@AlejandroGV:~$ dig +short www.alexgv.gonzalonazareno.org
hera.alexgv.gonzalonazareno.org.
~~~

4. Una resolución de bd.

### Interna

~~~
debian@apolo:~$ dig +short bd.alexgv.gonzalonazareno.org
ares.alexgv.gonzalonazareno.org.
10.0.1.101
~~~

### Externa

~~~
alejandrogv@AlejandroGV:~$ dig +short bd.alexgv.gonzalonazareno.org
ares.alexgv.gonzalonazareno.org.
~~~

5. Un resolución inversa de IP fija en cada una de las redes.

~~~
debian@zeus:~$ dig +short -x 10.0.1.101
ares.1.0.10.in-addr.arpa.

debian@zeus:~$ dig +short -x 172.16.0.200
hera.16.172.in-addr.arpa
~~~

## Servidor web

* Para que podamos acceder debemos habilitar en el firewall los puertos 443, 80 y 53

~~~
[usuario@hera ~]$ sudo firewall-cmd --permanent --add-port=443/tcp
success
[usuario@hera ~]$ sudo firewall-cmd --permanent --add-port=80/tcp
success
[usuario@hera ~]$ sudo firewall-cmd --permanent --add-port=53/udp
success
[usuario@hera ~]$ sudo firewall-cmd --reload
success
~~~

* En Rocky los directorios sites-avaiable y sites-enabled no se crean por defecto, los crearemos nosotros:

~~~
[usuario@hera ~]$ sudo mkdir /etc/httpd/sites-enabled /etc/httpd/sites-available
~~~

* Ahora entraremos al fichero de configuración "/etc/httpd/conf/httpd.conf" para añadir sites-avaiable como nueva ruta comentando la última línea y añadiendo otra

~~~
#IncludeOptional conf.d/*.conf
IncludeOptional	sites-enabled/*.conf
~~~

**Directamente pasaremos a la configuración de un virtualhost**

~~~
[usuario@hera ~]$ cat /etc/httpd/sites-available/pagina.conf
<VirtualHost *:80>
    ServerName www.alexgv.gonzalonazareno.org
    DocumentRoot /var/www/alexgv

    <Directory /var/www/alexgv/>
        Options FollowSymLinks
        AllowOverride All
        Order deny,allow
        Allow from all

        <FilesMatch "\.php">
                SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost"
        </FilesMatch>

    </Directory>

    ErrorLog /var/www/alexgv/log/error.log
    CustomLog /var/www/alexgv/log/requests.log combined
</VirtualHost>
~~~

* Creamos el vínculo en sites-enabled y las carpetas necesarias en "/var/www/"

~~~
[hera@hera sites-available]$ sudo ln -s pagina.conf ../sites-enabled/
[hera@hera sites-available]$ sudo mkdir -p /var/www/alexgv/log
~~~

* Selinux nos dará problemas con los nuevos directorios, por ello debemos ejecutar los siguientes comandos y reiniciar el servicio httpd

~~~
[usuario@hera ~]$ sudo semanage fcontext -a -t httpd_log_t "/var/www/alexgv/log(/.*)?"
[usuario@hera ~]$ sudo restorecon -R -v /var/www/alexgv/log
Relabeled /var/www/alexgv/log from unconfined_u:object_r:httpd_sys_content_t:s0 to unconfined_u:object_r:httpd_log_t:s0
[usuario@hera ~]$ sudo setsebool -P httpd_unified 1
[usuario@hera ~]$ sudo systemctl restart httpd
~~~

* Comprobemos que funciona

![info](/dns_web_bbdd/1.png)

### Servidor Base de datos.

**Usaremos el gestor mariadb**

~~~
ubuntu@sancho:~$ sudo apt install mariadb-server
~~~

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

        [root@quijote ~]# mysql -u ale -p -h bd.alexgv.gonzalonazareno.org
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