title = "Monotorización con Zabbix"
description = ""
tags = [
    "ASO"
]
date = "2022-06-01"
menu = "main"

## Servicio

* Usaremos un sistema de montorización llamado zabbix. Está diseñado para monitorizar y registrar el estado de varios servicios de red, Servidores, y hardware de red. Puede realizar:

  * Chequeos simples que pueden verificar la disponibilidad y el nivel de respuesta de servicios estándar como SMTP o HTTP sin necesidad de instalar ningún software sobre el host monitorizado.

  * Monitorizar estadísticas como carga de CPU, utilización de red, espacio en disco, etc.

* Caracteristicas:

  * Alto rendimiento y alta capacidad (posibilidad de monitorizar cientos de miles de dispositivos)

  * Auto descubrimiento de servidores y dispositivos de red

  * Monitorización distribuida y una administración web centralizada

  * Agentes nativos en múltiples plataformas

  * Monitorización Web

  * Configuración de permisos por usuarios y grupos

  * Sistema flexible de notificación de eventos

## Instalación

* Descargamos e instalamos el repositorio (La instalación de este servicio se hará en hera).

~~~
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
~~~

* También debemos instalar una seria de dependencias que necesitaremos.

~~~
[usuario@hera ~]$ sudo dnf install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent
~~~

* Ahora nos dirigimos a ares donde se encuentra la base de datos, crearemos una para este servicio.

~~~
MariaDB [(none)]> CREATE DATABASE zabbix character set utf8 collate utf8_bin;
Query OK, 1 row affected (0.012 sec)

MariaDB [(none)]> CREATE USER 'zabbix'@'172.16.0.200' identified by 'zabbix';
Query OK, 0 rows affected (0.046 sec)

MariaDB [(none)]> grant all privileges on zabbix.* to 'zabbix'@'172.16.0.200';
Query OK, 0 rows affected (0.005 sec)
~~~

* Importamos en la base de datos el esquema inicial.

~~~
[root@hera ~]# zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -u zabbix -p zabbix -h bd.alexgv.gonzalonazareno.org
~~~

* Nos dirigimos al fichero `/etc/zabbix/zabbix_server.conf` donde especificaremos el host de la base de datos y las credenciales para entrar.

~~~
DBHost=bd.alexgv.gonzalonazareno.org
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix
~~~

* Reiniciamos los siguientes servicios.

~~~
[root@hera ~]# systemctl restart zabbix-server.service zabbix-agent.service httpd.service php-fpm.service
~~~

* Nos dirigimos a la interfaz web donde terminaremos la instalación.

![principal](/monotorizacion/1.png)

* Configuramos la conexión a la base de datos.

![bd](/monotorizacion/2.png)

* Así quedaría la configuración.

![conf](/monotorizacion/3.png)

* El usuario y la contraseña por defecto serán 'Admin' y 'zabbix'.

![entrar](/monotorizacion/4.png)

* Ya estamos dentro.

![dentro](/monotorizacion/5.png)

## Clientes

* Vamos a instalar y configurar los clientes:

* Instalamos el agente de zabbix.

~~~
root@ares:~# wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-1+ubuntu20.04_all.deb

root@ares:~# dpkg -i zabbix-release_6.0-2+ubuntu20.04_all.deb 

root@ares:~# apt install zabbix-agent
~~~

* Nos dirigimos al fichero `/etc/zabbix/zabbix_agentd.conf` y configuramos los siguientes parametros para especificar cual es nuestro servidor.

~~~
Server=172.16.0.200
ServerActive=172.16.0.200
~~~

* Esto lo hariamos en todos los clientes. Ahora volvemos a nuestra interfaz web para añadir estos nuevos hosts, y nos dirigimos a la pestaña `Configuration > hosts`.

![hosts](/monotorizacion/6.png)

* Pulsamos en create host arriba a la derecha.

![create](/monotorizacion/7.png)

* El apartado de hosts lo dejamos así:

![hosts](/monotorizacion/8.png)

* Seguidamente nos dirigimos a templates y ponemos la que aparece `Template OS Linux by Zabbix agent`.

![template](/monotorizacion/9.png)

* Ya hemos añadido todos los hosts.

![hosts](/monotorizacion/10.png)

* Vemos que si entramos en la pestaña `Monitoring > hosts` aparecen todos.

![monitoring](/monotorizacion/11.png)

* Si entramos en cualquiera de ellos podemos ver mucha información.

![info](/monotorizacion/12.png)

## Alertas

### Servidor Web

* Empezaremos creando una alerta para ver la disponibilidad de nuestro servidor web, para ello nos dirigimos a `Configuration > hosts` y pulsamos sobre web en este caso en el servidor zabbix, que es el que tiene el servidor web.

![web](/monotorizacion/13.png)

* Una vez dentro creamos un nuevo escenario web.

![escenario](/monotorizacion/14.png)

* El escenario principal será tal que así.

![principal](/monotorizacion/15.png)

* Nos dirigimos a "steps" y creamos un nuevo paso, donde debemos especificar la url a monitorizar, y el codigo que debe darnos, he puesto el 200 pues es el que se devuelve en caso de que todo funcione correctamente.

![paso](/monotorizacion/16.png)

* Ya lo hemos creado.

![creado](/monotorizacion/17.png)

* Ya tenemos la alerta creada, sin embargo no se nos avisará en caso de que ocurra algo, para ello debemos crear un trigger. Nos dirigimos al apartado de triggers y arriba a la derecha clicamos el crear trigger.

![trigger](/monotorizacion/18.png)

* Creamos el trigger.

![creacion](/monotorizacion/19.png)

## Correo

* Vamos a configurar zabbix para que las alertas nos lleguen por correo. Para ello nos dirigimos a `Administration > Media Types` y ahí veremos el sin fin de opciones que tenemos para configurar zabbix.

![opciones](/monotorizacion/20.png)

* Vamos a elegir el correo electrónico y rellenamos los datos.

![datos](/monotorizacion/21.png)

* Ahora nos dirigimos a `Configuration > Actions` y creamos una acción, que será la que nos envie el correo cuando se active el trigger.

![acciones](/monotorizacion/22.png)

![operaciones](/monotorizacion/23.png)