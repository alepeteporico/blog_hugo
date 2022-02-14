+++
title = "Ejercicios kubernetes"
description = ""
tags = [
    "HLC"
]
date = "2022-02-03"
menu = "main"
+++

### Ejercicio 1

* Fichero yaml que has creado con la definición del Pod.

~~~
apiVersion: v1
kind: Pod
metadata:
  name: pod-ejercicio1
  labels:
    app: nginx
    service: web
  spec:
    containers:
      image: iesgn/test_web:latest
      name: contenedor-ejercicio1
      imagePullPolicy: Always
~~~

* Comprobación de que el Pod ha sido creado.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/1$ kubectl apply -f ejercicio1.yml 
pod/pod-ejercicio1 created
~~~