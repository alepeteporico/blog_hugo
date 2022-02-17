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

* Pantallazo con la salida de `minikube status` y pantallazo con la salida de `kubectl get nodes -o wide`.

~~~
alejandrogv@AlejandroGV:~$ minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

alejandrogv@AlejandroGV:~$ kubectl get nodes -o wide
NAME       STATUS   ROLES                  AGE     VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE              KERNEL-VERSION   CONTAINER-RUNTIME
minikube   Ready    control-plane,master   6d23h   v1.23.1   192.168.39.156   <none>        Buildroot 2021.02.4   4.19.202         docker://20.10.12
~~~

### Ejercicio 2

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

* Crea el Pod.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/1$ kubectl apply -f ejercicio1.yml 
pod/pod-ejercicio1 created
~~~

* Comprobación de que el Pod ha sido creado.

~~~
alejandrogv@AlejandroGV:~$ kubectl get pods
NAME             READY   STATUS    RESTARTS   AGE
pod-ejercicio1   1/1     Running   1          6d21h
~~~

* información detallada del Pod creado.

~~~
alejandrogv@AlejandroGV:~$ kubectl describe pod pod-ejercicio1
Name:         pod-ejercicio1
Namespace:    default
Priority:     0
Node:         minikube/192.168.39.156
Start Time:   Thu, 10 Feb 2022 11:58:47 +0100
Labels:       app=apache2
              service=web
Annotations:  <none>
Status:       Running
IP:           172.17.0.3
IPs:
  IP:  172.17.0.3
Containers:
  contenedor-ejercicio1:
    Container ID:   docker://69212c4621beece79ccc6266d8afbaf06e30da217f19531e46fb3d344bcd0229
    Image:          iesgn/test_web:latest
    Image ID:       docker-pullable://iesgn/test_web@sha256:001e1f4d8ab5d7ddf406e481392052769d1e87bdcce672fc6b91cdf3ec136886
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 17 Feb 2022 09:28:17 +0100
    Ready:          True
    Restart Count:  1
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rhl9c (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-rhl9c:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6d21h  default-scheduler  Successfully assigned default/pod-ejercicio1 to minikube
  Normal  Pulling    6d21h  kubelet            Pulling image "iesgn/test_web:latest"
  Normal  Pulled     6d21h  kubelet            Successfully pulled image "iesgn/test_web:latest" in 49.133079538s
  Normal  Created    6d21h  kubelet            Created container contenedor-ejercicio1
  Normal  Started    6d21h  kubelet            Started container contenedor-ejercicio1
  Normal  Pulling    26m    kubelet            Pulling image "iesgn/test_web:latest"
  Normal  Pulled     26m    kubelet            Successfully pulled image "iesgn/test_web:latest" in 11.274157179s
  Normal  Created    26m    kubelet            Created container contenedor-ejercicio
~~~

* Accede de forma interactiva al Pod y comprueba los ficheros que están en el DocumentRoot (usr/local/apache2/htdocs/).

~~~
alejandrogv@AlejandroGV:~$ kubectl exec -it pod-ejercicio1 -- ls /usr/local/apache2/htdocs/
index.html
~~~

* Crea una redirección con kubectl port-forward utilizando el puerto de localhost 8888 y sabiendo que el Pod ofrece el servicio en el puerto 80. Accede a la aplicación desde un navegador.

~~~
lejandrogv@AlejandroGV:~$ kubectl port-forward pod-ejercicio1 8282:80
Forwarding from 127.0.0.1:8282 -> 80
Forwarding from [::1]:8282 -> 80
~~~

[conexión](/ejercicios_kubernetes/1.png)

* Muestra los logs del Pod y comprueba que se visualizan los logs de los accesos que hemos realizado en el punto anterior.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/1$ kubectl logs pod-ejercicio1
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.3. Set the 'ServerName' directive globally to suppress this message
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.3. Set the 'ServerName' directive globally to suppress this message
[Thu Feb 17 10:04:46.032605 2022] [mpm_event:notice] [pid 1:tid 139668980692096] AH00489: Apache/2.4.46 (Unix) configured -- resuming normal operations
[Thu Feb 17 10:04:46.032835 2022] [core:notice] [pid 1:tid 139668980692096] AH00094: Command line: 'httpd -D FOREGROUND'
127.0.0.1 - - [17/Feb/2022:10:05:06 +0000] "GET /favicon.ico HTTP/1.1" 404 196
~~~

### Ejercicio 3

