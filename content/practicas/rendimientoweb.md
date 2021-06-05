+++
title = "Aumento de rendimiento de servidores web von Varnish"
description = ""
tags = [
    "HLC"
]
date = "2021-06-05"
menu = "main"
+++

* Instalamos ansible

        alejandrogv@AlejandroGV:~$ sudo apt install ansible

* Ahora clonaremos el repositorio correspondiente con la receta.

        alejandrogv@AlejandroGV:~$ git clone https://github.com/josedom24/ansible_nginx_fpm_php.git

* En el interior del respositorio editaremos el fichero hosts añadiendo la dirección de la máquina que usaremos para las pruebas.

        [servidores_web]
        nodo1 ansible_ssh_host=172.22.100.15 ansible_python_interpreter=/usr/bin/python3

* Ejecutamos la funcionalidad playbook de ansible para que se realicen las modificaciones necesarias que usaremos en la máquina de prueba.

alejandrogv@AlejandroGV:~/ansible_nginx_fpm_php$ ansible-playbook site.yaml 

        PLAY [servidores_web] ***********************************************************************************

        TASK [Gathering Facts] **********************************************************************************
        ok: [nodo1]

        TASK [nginx : install nginx, php-fpm] *******************************************************************
        changed: [nodo1]

        TASK [nginx : Copy info.php] ****************************************************************************
        changed: [nodo1]

        TASK [nginx : Copy virtualhost default] *****************************************************************
        changed: [nodo1]

        RUNNING HANDLER [nginx : restart nginx] *****************************************************************
        changed: [nodo1]

        PLAY [servidores_web] ***********************************************************************************

        TASK [Gathering Facts] **********************************************************************************
        ok: [nodo1]

        TASK [mariadb : ensure mariadb is installed] ************************************************************
        changed: [nodo1]

        TASK [mariadb : ensure mariadb binds to internal interface] *********************************************
        changed: [nodo1]

        RUNNING HANDLER [mariadb : restart mariadb] *************************************************************
        changed: [nodo1]

        PLAY [servidores_web] ***********************************************************************************

        TASK [Gathering Facts] **********************************************************************************
        ok: [nodo1]

        TASK [wordpress : install unzip] ************************************************************************
        changed: [nodo1]

        TASK [wordpress : download wordpress] *******************************************************************
        changed: [nodo1]

        TASK [wordpress : unzip wordpress] **********************************************************************
        changed: [nodo1]

        TASK [wordpress : create database wordpress] ************************************************************
        changed: [nodo1]

        TASK [wordpress : create user mysql wordpress] **********************************************************
        changed: [nodo1] => (item=localhost)

        TASK [wordpress : copy wp-config.php] *******************************************************************
        changed: [nodo1]

        RUNNING HANDLER [wordpress : restart nginx] *************************************************************
        changed: [nodo1]

        PLAY RECAP **********************************************************************************************
        nodo1                      : ok=17   changed=14   unreachable=0    failed=0  

* Accedemos a la página y vemos que ya tenemos nuestro wordpress que solamente deberemos configurar.

![volumen](/varnish/1.png)

* En la máquina de pruebas instalaremos la siguiente utilidad de apache

        vagrant@varnish:~$ sudo apt install apache2-utils 

* Vamos a realizar algunas pruebas de rendimiento, cambiando el nivel de concurrencia en cada una para testear el número de peticiones que puede realizar por segundo.

        vagrant@varnish:~$ ab -t 10 -c 50 -k http://127.0.0.1/wordpress/index.php
        This is ApacheBench, Version 2.3 <$Revision: 1843412 $>
        Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
        Licensed to The Apache Software Foundation, http://www.apache.org/

        Benchmarking 127.0.0.1 (be patient)
        Finished 1257 requests


        Server Software:        nginx/1.14.2
        Server Hostname:        127.0.0.1
        Server Port:            80

        Document Path:          /wordpress/index.php
        Document Length:        0 bytes

        Concurrency Level:      50
        Time taken for tests:   10.004 seconds
        Complete requests:      1257
        Failed requests:        0
        Non-2xx responses:      1257
        Keep-Alive requests:    0
        Total transferred:      272769 bytes
        HTML transferred:       0 bytes
        Requests per second:    125.65 [#/sec] (mean)
        Time per request:       397.917 [ms] (mean)
        Time per request:       7.958 [ms] (mean, across all concurrent requests)
        Transfer rate:          26.63 [Kbytes/sec] received

        Connection Times (ms)
                      min  mean[+/-sd] median   max
        Connect:        0    0   0.4      0       2
        Processing:    21  389  48.4    393     501
        Waiting:       21  389  48.4    393     501
        Total:         23  390  48.1    393     501

        Percentage of the requests served within a certain time (ms)
          50%    393
          66%    400
          75%    405
          80%    408
          90%    417
          95%    437
          98%    478
          99%    487
         100%    501 (longest request)

----------------------------------------------------------------------------------------------

        vagrant@varnish:~$ sudo systemctl restart nginx.service 
        vagrant@varnish:~$ ab -t 10 -c 100 -k http://127.0.0.1/wordpress/index.php
        This is ApacheBench, Version 2.3 <$Revision: 1843412 $>
        Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
        Licensed to The Apache Software Foundation, http://www.apache.org/

        Benchmarking 127.0.0.1 (be patient)
        Finished 1343 requests


        Server Software:        nginx/1.14.2
        Server Hostname:        127.0.0.1
        Server Port:            80

        Document Path:          /wordpress/index.php
        Document Length:        0 bytes

        Concurrency Level:      100
        Time taken for tests:   10.005 seconds
        Complete requests:      1343
        Failed requests:        0
        Non-2xx responses:      1343
        Keep-Alive requests:    0
        Total transferred:      291431 bytes
        HTML transferred:       0 bytes
        Requests per second:    134.23 [#/sec] (mean)
        Time per request:       744.972 [ms] (mean)
        Time per request:       7.450 [ms] (mean, across all concurrent requests)
        Transfer rate:          28.45 [Kbytes/sec] received

        Connection Times (ms)
                      min  mean[+/-sd] median   max
        Connect:        0    0   0.5      0       3
        Processing:    19  716 111.3    741     787
        Waiting:       16  716 111.3    741     787
        Total:         19  716 110.8    741     787

        Percentage of the requests served within a certain time (ms)
          50%    741
          66%    746
          75%    749
          80%    751
          90%    756
          95%    759
          98%    764
          99%    766
         100%    787 (longest request)

-----------------------------------------------------------------------

        vagrant@varnish:~$ sudo systemctl restart nginx.service 
        vagrant@varnish:~$ ab -t 10 -c 250 -k http://127.0.0.1/wordpress/index.php
        This is ApacheBench, Version 2.3 <$Revision: 1843412 $>
        Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
        Licensed to The Apache Software Foundation, http://www.apache.org/

        Benchmarking 127.0.0.1 (be patient)
        Completed 5000 requests
        Completed 10000 requests
        Completed 15000 requests
        Completed 20000 requests
        Completed 25000 requests
        Completed 30000 requests
        Completed 35000 requests
        Completed 40000 requests
        Completed 45000 requests
        Completed 50000 requests
        Finished 50000 requests


        Server Software:        nginx/1.14.2
        Server Hostname:        127.0.0.1
        Server Port:            80

        Document Path:          /wordpress/index.php
        Document Length:        0 bytes

        Concurrency Level:      250
        Time taken for tests:   4.719 seconds
        Complete requests:      50000
        Failed requests:        49580
           (Connect: 0, Receive: 0, Length: 49580, Exceptions: 0)
        Non-2xx responses:      50000
        Keep-Alive requests:    49254
        Total transferred:      16450910 bytes
        HTML transferred:       8577340 bytes
        Requests per second:    10594.75 [#/sec] (mean)
        Time per request:       23.597 [ms] (mean)
        Time per request:       0.094 [ms] (mean, across all concurrent requests)
        Transfer rate:          3404.17 [Kbytes/sec] received

        Connection Times (ms)
                      min  mean[+/-sd] median   max
        Connect:        0    0   1.5      0      25
        Processing:     0   20 128.8      8    1960
        Waiting:        0   20 128.8      8    1960
        Total:          0   20 129.3      8    1972

        Percentage of the requests served within a certain time (ms)
          50%      8
          66%     10
          75%     12
          80%     13
          90%     18
          95%     23
          98%     29
          99%     56
         100%   1972 (longest request)

---------------------------------------------------------------------

        vagrant@varnish:~$ sudo systemctl restart nginx.service 
        vagrant@varnish:~$ ab -t 10 -c 500 -k http://127.0.0.1/wordpress/index.php
        This is ApacheBench, Version 2.3 <$Revision: 1843412 $>
        Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
        Licensed to The Apache Software Foundation, http://www.apache.org/

        Benchmarking 127.0.0.1 (be patient)
        Completed 5000 requests
        Completed 10000 requests
        Completed 15000 requests
        Completed 20000 requests
        Completed 25000 requests
        Completed 30000 requests
        Completed 35000 requests
        Completed 40000 requests
        Completed 45000 requests
        Completed 50000 requests
        Finished 50000 requests


        Server Software:        nginx/1.14.2
        Server Hostname:        127.0.0.1
        Server Port:            80

        Document Path:          /wordpress/index.php
        Document Length:        0 bytes

        Concurrency Level:      500
        Time taken for tests:   3.798 seconds
        Complete requests:      50000
        Failed requests:        49709
           (Connect: 0, Receive: 0, Length: 49709, Exceptions: 0)
        Non-2xx responses:      50000
        Keep-Alive requests:    49494
        Total transferred:      16466042 bytes
        HTML transferred:       8599657 bytes
        Requests per second:    13163.55 [#/sec] (mean)
        Time per request:       37.984 [ms] (mean)
        Time per request:       0.076 [ms] (mean, across all concurrent requests)
        Transfer rate:          4233.43 [Kbytes/sec] received

        Connection Times (ms)
                      min  mean[+/-sd] median   max
        Connect:        0    0   2.7      0      32
        Processing:     0   29 124.8      8    2497
        Waiting:        0   29 124.7      8    2494
        Total:          0   29 125.6      8    2497

        Percentage of the requests served within a certain time (ms)
          50%      8
          66%     34
          75%     40
          80%     43
          90%     51
          95%     57
          98%     66
          99%     76
         100%   2497 (longest request)

---------------------------------------------------------

#### 50

125.65 [#/sec] (mean)

#### 100

134.23 [#/sec] (mean)

#### 250

10594.75 [#/sec] (mean)

#### 500

13163.55 [#/sec] (mean)

* Nuestro siguiente paso será configurar varnish, un proxy inverso que escucha por el puerto 80 y se comunicará por el puerto 8080 con el servidor web.

        vagrant@varnish:~$ sudo apt install varnish

* Debemos configurar el fichero `/etc/nginx/sites-available/default` para que escuche por el puerto 8080.

        server {
                listen 8080 default_server;
                listen [::]:8080 default_server;

* Nos dirigimos a los ficheros de configuración necesarios para que varnish escuche por el puerto 80 y redirija el tráfico por el puerto 8080.

#### /etc/varnish/default.vcl

        backend default {
            .host = "127.0.0.1";
            .port = "8080";
        }

-------------------------------------------

#### /etc/default/varnish

        DAEMON_OPTS="-a :80 \
                     -T localhost:6082 \
                     -f /etc/varnish/default.vcl \
                     -S /etc/varnish/secret \
                     -s malloc,256m"

#### /lib/systemd/system/varnish.service

        ExecStart=/usr/sbin/varnishd -j unix,user=vcache -F -a :80 -T localhost:6082 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s malloc,256m

* Vamos a realizar las mismas pruebas que realizamos anteriormente.

        vagrant@varnish:~$ ab -t 10 -c 50 -k http://127.0.0.1/
        Requests per second:    26343.35 [#/sec] (mean)

        vagrant@varnish:~$ ab -t 10 -c 100 -k http://127.0.0.1/
        Requests per second:    25893.24 [#/sec] (mean)

        vagrant@varnish:~$ ab -t 10 -c 250 -k http://127.0.0.1/
        Requests per second:    22141.36 [#/sec] (mean)

        vagrant@varnish:~$ ab -t 10 -c 500 -k http://127.0.0.1/
        Requests per second:    25532.39 [#/sec] (mean)

* Comprobamos que ahora se hacen muchas más peticiones gracias a nuestro proxy inverso.