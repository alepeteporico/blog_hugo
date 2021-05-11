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

* 