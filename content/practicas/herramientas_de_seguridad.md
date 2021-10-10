+++
title = "Herramientas de seguridad"
description = ""
tags = [
    "SAD"
]
date = "2021-09-23"
menu = "main"
+++

---

## Sistemas de detección de intrusos

---------------------------

#### Vamos a usar como sistema de detección de intrusos la herramienta SURICATA, parece ser la más usada a día de hoy 

---------------------------

* Vamos a instalar el paquete de suricata y oinkmaster que usaremos mas adelante.

~~~
root@suricata:~# apt install suricata
~~~

* La instalación ha sido sencilla, para configurar los parametros básicos iremos al fichero `/etc/suricata/suricata.yaml`, lo primero que haremos será asegurarnos que suricata escucha por la interfaz correcta. Si esto no fuera así simplemente cambiamos el nombre de la interfaz.

~~~
# Linux high speed capture support
af-packet:
  - interface: eth0
~~~

* Ya debería estar funcionando, sin embargo no hemos especficado que tiene que buscar, para ello instalaremos el paquete `suricata-oinkmaster`

~~~
root@suricata:~# apt install suricata-oinkmaster
~~~

* Y usando el comando que aparece a continuación se instalarán algunas reglas básicas.

~~~
vagrant@suricata:~$ sudo suricata-oinkmaster-updater
~~~

* Comprobamos todos los fichero de reglas que se han configurado.

~~~
vagrant@suricata:~$ ls /etc/suricata/rules/
3coresec.rules                  emerging-ftp.rules             emerging-trojan.rules
BSD-License.txt                 emerging-games.rules           emerging-user_agents.rules
app-layer-events.rules          emerging-icmp.rules            emerging-voip.rules
botcc.portgrouped.rules         emerging-icmp_info.rules       emerging-web_client.rules
botcc.rules                     emerging-imap.rules            emerging-web_server.rules
ciarmy.rules                    emerging-inappropriate.rules   emerging-web_specific_apps.rules
classification.config           emerging-info.rules            emerging-worm.rules
compromised-ips.txt             emerging-malware.rules         files.rules
compromised.rules               emerging-misc.rules            gpl-2.0.txt
decoder-events.rules            emerging-mobile_malware.rules  http-events.rules
dhcp-events.rules               emerging-netbios.rules         ipsec-events.rules
dnp3-events.rules               emerging-p2p.rules             kerberos-events.rules
dns-events.rules                emerging-policy.rules          modbus-events.rules
drop.rules                      emerging-pop3.rules            nfs-events.rules
dshield.rules                   emerging-rpc.rules             ntp-events.rules
emerging-activex.rules          emerging-scada.rules           sid-msg.map
emerging-attack_response.rules  emerging-scan.rules            smb-events.rules
emerging-chat.rules             emerging-shellcode.rules       smtp-events.rules
emerging-current_events.rules   emerging-smtp.rules            stream-events.rules
emerging-deleted.rules          emerging-snmp.rules            suricata-4.0-enhanced-open.txt
emerging-dns.rules              emerging-sql.rules             tls-events.rules
emerging-dos.rules              emerging-telnet.rules          tor.rules
emerging-exploit.rules          emerging-tftp.rules
~~~

* Ahora vamos a crear una regla bastante simple solamente a modo de prueba, crearemos un fichero en `/etc/suricata/rules/` donde añadiremos la siguiente regla que simplemente saltará una alerta cada vez que se detecte un paquete ICMP y esto será visible en los logs.

~~~
alert icmp any any -> any any (msg: "ICMP detected";)
~~~

* Y en el fichero de configuración de suricata añadimos nuestro fichero de reglas, podriamos hacer diferentes ficheros dependiendo de criterios como: tipo de servicios, entrada, salida, etc...

~~~
rule-files:
  - prueba.rules
  - suricata.rules
  - 3coresec.rules
  - BSD-License.txt
  - app-layer-events.rules
  - botcc.portgrouped.rules
  - botcc.rules
  - ciarmy.rules
  - classification.config
  - compromised-ips.txt
  - compromised.rules
  - decoder-events.rules
  - dhcp-events.rules
  - dnp3-events.rules
  - dns-events.rules
  - drop.rules
  - dshield.rules
  - emerging-activex.rules
  - emerging-attack_response.rules
  - emerging-chat.rules
  - emerging-current_events.rules
  - emerging-deleted.rules
  - emerging-dns.rules
  - emerging-dos.rules
  - emerging-exploit.rules
  - emerging-ftp.rules
  - emerging-games.rules
  - emerging-icmp.rules
  - emerging-icmp_info.rules
  - emerging-imap.rules
  - emerging-inappropriate.rules
  - emerging-info.rules
  - emerging-malware.rules
  - emerging-misc.rules
  - emerging-mobile_malware.rules
  - emerging-netbios.rules
  - emerging-p2p.rules
  - emerging-policy.rules
  - emerging-pop3.rules
  - emerging-rpc.rules
  - emerging-scada.rules
  - emerging-scan.rules
  - emerging-shellcode.rules
  - emerging-smtp.rules
  - emerging-snmp.rules
  - emerging-sql.rules
  - emerging-telnet.rules
  - emerging-tftp.rules
  - emerging-trojan.rules
  - emerging-user_agents.rules
  - emerging-voip.rules
  - emerging-web_client.rules
  - emerging-web_server.rules
  - emerging-web_specific_apps.rules
  - emerging-worm.rules
  - files.rules
  - gpl-2.0.txt
  - http-events.rules
  - ipsec-events.rules
  - kerberos-events.rules
  - modbus-events.rules
  - nfs-events.rules
  - ntp-events.rules
  - sid-msg.map
  - smb-events.rules
  - smtp-events.rules
  - stream-events.rules
  - suricata-4.0-enhanced-open.txt
  - tls-events.rules
  - tor.rules
~~~

* Todas las reglas expecto la primera que hemos añadido nosotros son las que se han añadido con el `suricata-oinkmaster-updater`.

* Reiniciaremos el servicio y veremos el estado del mismo.

~~~
root@suricata:~# sudo systemctl reload suricata

root@suricata:~# sudo systemctl status suricata
● suricata.service - Suricata IDS/IDP daemon
     Loaded: loaded (/lib/systemd/system/suricata.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2021-09-30 11:16:33 UTC; 18min ago
       Docs: man:suricata(8)
             man:suricatasc(8)
             https://suricata-ids.org/docs/
    Process: 7126 ExecStart=/usr/bin/suricata -D --af-packet -c /etc/suricata/suricata.yaml --pidfile /r>
    Process: 7296 ExecReload=/usr/bin/suricatasc -c reload-rules (code=exited, status=0/SUCCESS)
    Process: 7297 ExecReload=/bin/kill -HUP $MAINPID (code=exited, status=0/SUCCESS)
   Main PID: 7127 (Suricata-Main)
      Tasks: 7 (limit: 528)
     Memory: 367.0M
        CPU: 1min 10.711s
     CGroup: /system.slice/suricata.service
             └─7127 /usr/bin/suricata -D --af-packet -c /etc/suricata/suricata.yaml --pidfile /run/suric>

Sep 30 11:16:33 suricata systemd[1]: Starting Suricata IDS/IDP daemon...
Sep 30 11:16:33 suricata suricata[7126]: 30/9/2021 -- 11:16:33 - <Notice> - This is Suricata version 6.0>
Sep 30 11:16:33 suricata systemd[1]: suricata.service: Can't open PID file /run/suricata.pid (yet?) afte>
Sep 30 11:16:33 suricata systemd[1]: Started Suricata IDS/IDP daemon.
Sep 30 11:34:45 suricata systemd[1]: Reloading Suricata IDS/IDP daemon.
Sep 30 11:35:10 suricata suricatasc[7296]: {"message": "done", "return": "OK"}
Sep 30 11:35:10 suricata systemd[1]: Reloaded Suricata IDS/IDP daemon.
~~~

* En el fichero `fast.log` podremos ver si ha habido alguna alerta de nuestra aplicación.

~~~
vagrant@suricata:~$ tail -f /var/log/suricata/fast.log
10/03/2021-18:23:49.243586  [**] [1:0:0] ICMP detected [**] [Classification: (null)] [Priority: 3] {ICMP} 192.168.121.44:8 -> 8.8.8.8:0
10/03/2021-18:23:49.264020  [**] [1:0:0] ICMP detected [**] [Classification: (null)] [Priority: 3] {ICMP} 8.8.8.8:0 -> 192.168.121.44:0
10/03/2021-18:24:18.439774  [**] [1:2013504:5] ET POLICY GNU/Linux APT User-Agent Outbound likely related to package management [**] [Classification: Not Suspicious Traffic] [Priority: 3] {TCP} 192.168.121.44:56238 -> 199.232.182.132:80
10/03/2021-18:24:18.487175  [**] [1:2013504:5] ET POLICY GNU/Linux APT User-Agent Outbound likely related to package management [**] [Classification: Not Suspicious Traffic] [Priority: 3] {TCP} 192.168.121.44:56238 -> 199.232.182.132:80
10/03/2021-18:24:18.487175  [**] [1:2013504:5] ET POLICY GNU/Linux APT User-Agent Outbound likely related to package management [**] [Classification: Not Suspicious Traffic] [Priority: 3] {TCP} 192.168.121.44:56238 -> 199.232.182.132:80
10/03/2021-18:24:18.487175  [**] [1:2013504:5] ET POLICY GNU/Linux APT User-Agent Outbound likely related to package management [**] [Classification: Not Suspicious Traffic] [Priority: 3] {TCP} 192.168.121.44:56238 -> 199.232.182.132:80
10/03/2021-18:24:18.487175  [**] [1:2013504:5] ET POLICY GNU/Linux APT User-Agent Outbound likely related to package management [**] [Classification: Not Suspicious Traffic] [Priority: 3] {TCP} 192.168.121.44:56238 -> 199.232.182.132:80
10/03/2021-18:24:18.487175  [**] [1:2013504:5] ET POLICY GNU/Linux APT User-Agent Outbound likely related to package management [**] [Classification: Not Suspicious Traffic] [Priority: 3] {TCP} 192.168.121.44:56238 -> 199.232.182.132:80
10/03/2021-18:26:24.036738  [**] [1:0:0] ICMP detected [**] [Classification: (null)] [Priority: 3] {IPv6-ICMP} fe80:0000:0000:0000:fc54:00ff:fe02:38c7:133 -> ff02:0000:0000:0000:0000:0000:0000:0002:0
10/03/2021-19:23:11.905888  [**] [1:0:0] ICMP detected [**] [Classification: (null)] [Priority: 3] {IPv6-ICMP} fe80:0000:0000:0000:fc54:00ff:fe02:38c7:133 -> ff02:0000:0000:0000:0000:0000:0000:0002:0
~~~

* Una vez hecho esto debemos saber que las reglas que estamos aplicando son reglas "snort" una vez sepamos esto la busqueda de reglas que se apliquen a nuestras necesidades son muy faciles, por ejemplo, hagamos una regla que nos avise si hay estamos teniendo un ataque por fuerza bruta ssh, la regla sería la siguiente, veamosla entera y después la analizaremos.

~~~
alert tcp $EXTERNAL_NET any -> $HOME_NET 22 (msg:"SCAN SSH BRUTE FORCE login attempt"; GID:1; sid:10000011; rev:001; flow:to_server,established; content:"SSH-"; depth:4; detection_filter:track by_src, count 5, seconds 60; metadata:service ssh; classtype:misc-activity;)
~~~

--------------------------------

### Analizando ejemplo complejo de regla snort.

* `alert` aunque pueda parecer algo muy sencillo pero vamos a verlo todo paso a paso, este alert es la definición de lo que pasará cuando detecte la activación de esta regla, en este caso el tipo de alerta que hayamos definido, por defecto es la que vimos anteriormente la cual añade una entrada al log de suricata.

* `tcp $EXTERNAL_NET any` cualquier conexion que venga de fuera usando tcp usado para los ataques de fuerza bruta ssh.

* `$HOME_NET 22` Hacía nuestro puerto local 22.

* `msg:"SCAN SSH BRUTE FORCE login attempt";` el mensaje que aparecerá en el log.

* `GID:1; sid:10000011; rev:001;` números de referencia, como esta regla es inventada por nosotros podemos ponerle el que queramos, hay algunas ya establecidas que tienen su propio numero de referencia.

* `flow:to_server,established;` indicamos que la regla se aplique solo en uno de los sentidos, en este caso trafico entrante y con established indicamos en concreto TCP.

* `content:"SSH-"; depth:4;` Indicamos que el contenido del paquete entrante es ssh y con el depth simplemente hacemos mas eficiente esta regla, pues establece un número determinado de bytes a buscar en el payload del paquete (una carga que se ejecuta en una vulnerabilidad para aprovechar la misma) esto reducirá la carga enormemente.

* `detection_filter:track by_src, count 5, seconds 60;` el detection_filter:track by_src inicia un contador para el tráfico del tipo que hemos especificado proveniente de una misma IP, el contador y los segundos establecidos después indican que este contador podrá llegar como máximo a en 60 segundos antes de que salte la alerta.

* `metadata:service ssh;` simplemente un comparador para ver que el servicio que estamos intentando detectar es ssh.

* `classtype:misc-activity;` Para detectar el tipo de ataque que estamos sufriendo, en este caso un misc-activity.

### Prueba en máquina grupal.

* Hemos hecho una prueba de ataque con la herramienta hydra. Vemos en el log que nuestro sistema detecta el ataque con la regla que hemos visto para detectar ataques por fuerza bruta ssh.

~~~
davidrg@pc-256:~$ tail -f /var/log/suricata/fast.log
10/07/2021-12:49:13.180596  [**] [1:2260002:1] SURICATA Applayer Detect protocol only one direction [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 172.22.8.253:22 -> 172.22.6.58:41854
10/07/2021-12:50:04.295783  [**] [1:2260002:1] SURICATA Applayer Detect protocol only one direction [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 172.22.8.253:22 -> 172.22.6.58:41906
10/07/2021-12:50:51.543040  [**] [1:2260002:1] SURICATA Applayer Detect protocol only one direction [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 172.22.8.253:22 -> 172.22.6.58:41940
10/07/2021-12:50:51.648206  [**] [1:2260002:1] SURICATA Applayer Detect protocol only one direction [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 172.22.8.253:22 -> 172.22.6.58:41944
10/07/2021-12:50:51.660465  [**] [1:2260002:1] SURICATA Applayer Detect protocol only one direction [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 172.22.8.253:22 -> 172.22.6.58:41948
~~~

* Como vemos no indica la ip desde la que están haciendo este ataque de fuerza bruta