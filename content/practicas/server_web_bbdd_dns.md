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

**El servidor DNS estará instalado en freston, por ello instalaremos bind en esta máquina**

        root@freston:~# apt install bind9

**Configuramos el fichero "/etc/bind/named.conf.options" y añadimos las siguientes líneas:**

    listen-on { any };
	allow-transfer { none };
	recursion yes;
	allow-recursion { any; };

**Configuramos el DNS local, la DMZ y externa en el fichero de configuración /etc/bind/named.conf.local:**

        view interna {
                match-clients { 10.0.1.0/24; localhost; };

                zone "alegv.gonzalonazareno.org" {
                        type master;
                        file "db.alegv.interna";
                };

                zone "1.0.10.in-addr.arpa" {
                        type master;
                        file "db.1.0.10";
                };

                zone "2.0.10.in-addr.arpa" {
                        type master;
                        file "db.2.0.10";
                };

                include "/etc/bind/zones.rfc1918";
                include "/etc/bind/named.conf.default-zones";
        };
        view dmz {
                match-clients { 10.0.2.0/24; };

                zone "alegv.gonzalonazareno.org" {
                        type master;
                        file "db.alegv.dmz";
                };

                zone "1.0.10.in-addr.arpa" {
                        type master;
                        file "db.1.0.10";
                };

                zone "2.0.10.in-addr.arpa" {
                        type master;
                        file "db.2.0.10";
                };

                include "/etc/bind/zones.rfc1918";
                include "/etc/bind/named.conf.default-zones";
        };

        view externa {
                match-clients { 172.22.0.0/15; 192.168.202.2; };

                zone "alegv.gonzalonazareno.org" {
                        type master;
                        file "db.alegv.externa";
                };

                include "/etc/bind/zones.rfc1918";
                include "/etc/bind/named.conf.default-zones";
        };

**Y en el fichero "/etc/bind/named.conf" debemos comentar esta línea:**

        //include "/etc/bind/named.conf.default-zones";

**Crearemos los archivos db, lo hacemos en la carpeta "/var/cache/bind/"**

### db.alegv.interna

        $TTL    86400
        @       IN      SOA     freston.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. (
                                      1         ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                  86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      freston.alegv.gonzalonazareno.org.

        $ORIGIN alegv.gonzalonazareno.org.

        dulcinea        IN      A       10.0.1.8
        sancho  IN      A       10.0.1.6
        quijote IN      A       10.0.2.5
        freston IN      A       10.0.1.9
        www     IN      CNAME   quijote
        bd      IN      CNAME   sancho

### db.alegv.dmz

        $TTL    86400
        @       IN      SOA     freston.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. (
                                      1         ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                  86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      freston.alegv.gonzalonazareno.org.
        
        $ORIGIN alegv.gonzalonazareno.org.
        
        dulcinea        IN      A       10.0.2.10
        sancho  IN      A       10.0.1.6
        quijote IN      A       10.0.2.5
        freston IN      A       10.0.1.9
        www     IN      CNAME   quijote
        bd      IN      CNAME   sancho

### db.alegv.externa

        $TTL    86400
        @       IN      SOA     dulcinea.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. (
                                      1         ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                  86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      dulcinea.alegv.gonzalonazareno.org.

        $ORIGIN alegv.gonzalonazareno.org.

        dulcinea        IN      A       172.22.200.87
        www     IN      CNAME   dulcinea
        test    IN      CNAME   dulcinea

**Ahora crearemos los archivos de las resoluciones inversas en la misma ruta**

### db.1.0.10

        $TTL    86400
        @       IN      SOA     freston.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. (
                                      1         ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                  86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      freston.alegv.gonzalonazareno.org.


        $ORIGIN 1.0.10.in-addr.arpa.

        8       IN      PTR     dulcinea.alegv.gonzalonazareno.org.
        6       IN      PTR     sancho.alegv.gonzalonazareno.org.
        9       IN      PTR     freston.alegv.gonzalonazareno.org.

### db.2.0.10

        $TTL    86400
        @       IN      SOA     freston.alegv.gonzalonazareno.org. admin.alegv.gonzalonazareno.org. (
                                       1         ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                  86400 )       ; Negative Cache TTL
        ;
        @       IN      NS      freston.alegv.gonzalonazareno.org.
        
        
        $ORIGIN 2.0.10.in-addr.arpa.
        
        10      IN      PTR     dulcinea.alegv.gonzalonazareno.org.
        5       IN      PTR     quijote.alegv.gonzalonazareno.org.

**Si quisieramos asegurarnos de que no tenemos ningún error de sintáxis podemos usar esto:**

        root@freston:/var/cache/bind# named-checkconf

**IPV6 da conflictos, así que podemos deshabilitarlo en el fichero "/etc/default/bind9"**

        # run resolvconf?
        RESOLVCONF=yes

        # startup options for the server
        OPTIONS="-4 -u bind"

**Reiniciamos el servicio de DNS**

        root@freston:/var/cache/bind# systemctl restart bind9

        debian@freston:~$ sudo systemctl status bind9
        ● bind9.service - BIND Domain Name Server
           Loaded: loaded (/lib/systemd/system/bind9.service; enabled; vendor preset: enabled)
           Active: active (running) since Fri 2021-02-19 11:38:00 UTC; 1min 37s ago
             Docs: man:named(8)
          Process: 14513 ExecStart=/usr/sbin/named $OPTIONS (code=exited, status=0/SUCCESS)
         Main PID: 14514 (named)
            Tasks: 4 (limit: 562)
           Memory: 18.3M
           CGroup: /system.slice/bind9.service
                   └─14514 /usr/sbin/named -4 -u bind

        Feb 19 11:38:00 freston named[14514]: zone localhost/IN/externa: loaded serial 2
        Feb 19 11:38:00 freston named[14514]: all zones loaded
        Feb 19 11:38:00 freston systemd[1]: Started BIND Domain Name Server.
        Feb 19 11:38:00 freston named[14514]: running
        Feb 19 11:38:01 freston named[14514]: managed-keys-zone/interna: Key 20326 for zone . acceptance timer co
        Feb 19 11:38:01 freston named[14514]: resolver priming query complete
        Feb 19 11:38:01 freston named[14514]: managed-keys-zone/externa: Key 20326 for zone . acceptance timer co
        Feb 19 11:38:01 freston named[14514]: resolver priming query complete
        Feb 19 11:38:01 freston named[14514]: managed-keys-zone/dmz: Key 20326 for zone . acceptance timer comple
        Feb 19 11:38:01 freston named[14514]: resolver priming query complete

**Vamos a añadir las reglas en Dulcinea, lo haremos para el DNS (puerto 53) y como lo usaremos mas adelante, también para http (puerto 80) y https (puerto 443)**

        debian@dulcinea:~$ sudo nft add chain nat prerouting { type nat hook prerouting priority 0 \; }
        debian@dulcinea:~$ sudo nft add rule ip nat prerouting iifname "eth0" udp dport 53 counter dnat to 10.0.1.9
        debian@dulcinea:~$ sudo nft add rule ip nat prerouting iifname "eth0" tcp dport 80 counter dnat to 10.0.2.2
        debian@dulcinea:~$ sudo nft add rule ip nat prerouting iifname "eth0" tcp dport 443 counter dnat to 10.0.2.2

**Y guardamos los cambios**

        root@dulcinea:~# nft list ruleset > /etc/nftables.conf

**Vamos a cambiar el nombre de dominio local en los /etc/hosts de todas las máquinas**

### Dulciena

        127.0.1.1 dulcinea.alegv.gonzalonazareno.org dulcinea.novalocal dulcinea
        127.0.0.1 localhost

### Sancho

        127.0.0.1 sancho.alegv.gonzalonzareno.org
        127.0.0.1 localhost

### Feston

        127.0.1.1 freston.alegv.gonzalonzareno.org freston.novalocal freston
        127.0.0.1 localhost

### Quijote

        127.0.1.1 quijote.alegv.gonzalonazareno.org quijote

**Cambiamos los ficheros de resolv de todas las instanacias:**

### Dulcinea

        root@dulcinea:~# cat /etc/resolvconf/resolv.conf.d/head 
        nameserver 10.0.1.9

        root@dulcinea:~# cat /etc/resolvconf/resolv.conf.d/base 
        nameserver 192.168.202.2
        search alegv.gonzalonazareno.org

        root@dulcinea:~# cat /etc/resolv.conf 
        nameserver 10.0.1.9
        nameserver 192.168.200.2
        nameserver 192.168.202.2
        search alegv.gonzalonazareno.org

### Sancho

        ubuntu@sancho:~$ cat /etc/netplan/50-cloud-init.yaml
        network:
            version: 2
            ethernets:
                ens4:
                    dhcp4: false
                    match:
                        macaddress: fa:16:3e:8b:3f:fb
                    mtu: 8950
                    set-name: ens4
                    addresses: [10.0.1.6/24]
                    gateway4: 10.0.1.8
                    nameservers:
                        addresses: [192.168.202.2, 192.168.200.2, 1.0.1.9]
                        search: ["alegv.gonzalonazareno.org"]

        ubuntu@sancho:~$ cat /etc/resolv.conf 
                nameserver 127.0.0.53
                options edns0 trust-ad
                search alegv.gonzalonazareno.org

### Quijote

        [centos@quijote ~]$ cat /etc/resolv.conf 
        # Generated by NetworkManager
        search openstacklocal alegv.gonzalonazareno.org
        nameserver 10.0.1.9
        nameserver 192.168.202.2
        nameserver 192.168.200.2

### Freston

        debian@freston:~$ cat /etc/resolv.conf 
        nameserver 10.0.1.9
        nameserver 192.168.200.2
        nameserver 192.168.202.2
        search openstacklocal alegv.gonzalonazareno.org

        debian@freston:~$ cat /etc/resolvconf/resolv.conf.d/base
        nameserver 192.168.202.2
        search alegv.gonzalonazareno.org

        debian@freston:~$ cat /etc/resolvconf/resolv.conf.d/head 
        nameserver 10.0.1.9

**Nuestro siguiente paso será deshabilitar la seguirdad de los puertos y las máquinas:**

        (openstackclient) alejandrogv@AlejandroGV:~$ openstack server remove security group Quijote default
        (openstackclient) alejandrogv@AlejandroGV:~$ openstack port set --disable-port-security 3fd1ff15-8a86-4374-ab6b-5e946e9721c0

        (openstackclient) alejandrogv@AlejandroGV:~$ openstack server remove security group Freston default
        (openstackclient) alejandrogv@AlejandroGV:~$ openstack port set --disable-port-security bb44ccb2-b79e-497c-b271-4d9a8f3dadaa

        (openstackclient) alejandrogv@AlejandroGV:~$ openstack server remove security group Sancho default
        (openstackclient) alejandrogv@AlejandroGV:~$ openstack port set --disable-port-security a7c4213b-d224-4d2f-8cf1-1f8770ef7823

**Vamos a hacer las comprobaciones necesarias en cada máquina:**

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

        alejandrogv@AlejandroGV:~$ dig dulcinea.alegv.gonzalonazareno.org

        ; <<>> DiG 9.11.5-P4-5.1+deb10u3-Debian <<>> dulcinea.alegv.gonzalonazareno.org
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18016
        ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ; COOKIE: 0c19b93390596f9a67cc7a1960b76f3f5eee202006b6b4e9 (good)
        ;; QUESTION SECTION:
        ;dulcinea.alegv.gonzalonazareno.org. IN	A

        ;; ANSWER SECTION:
        dulcinea.alegv.gonzalonazareno.org. 86400 IN A	172.22.200.87

        ;; AUTHORITY SECTION:
        alegv.gonzalonazareno.org. 86400 IN	NS	dulcinea.alegv.gonzalonazareno.org.

        ;; Query time: 3 msec
        ;; SERVER: 192.168.202.2#53(192.168.202.2)
        ;; WHEN: mié jun 02 13:45:03 CEST 2021
        ;; MSG SIZE  rcvd: 121

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