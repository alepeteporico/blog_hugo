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

![conexión](/ejercicios_kubernetes/1.png)

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

* Fichero `yml` con la descripción del ReplicaSet.

~~~
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-ejercico2
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - image: iesgn/test_web:latest
          name: ejercicio2-pod
~~~

* Comprueba que el ReplicaSet y los 3 Pods se han creado

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/2$ kubectl get rs,pods
NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/replicaset-ejercico2   3         3         0       8s

NAME                             READY   STATUS              RESTARTS   AGE
pod/pod-ejercicio1               1/1     Running             1          5d23h
pod/replicaset-ejercico2-5v8p5   0/1     ContainerCreating   0          9s
pod/replicaset-ejercico2-fgfxl   0/1     ContainerCreating   0          9s
pod/replicaset-ejercico2-qw7lt   0/1     ContainerCreating   0          9s
~~~

* Ve la información detallada del ReplicaSet.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/2$ kubectl describe rs replicaset-ejercico2
Name:         replicaset-ejercico2
Namespace:    default
Selector:     app=nginx
Labels:       <none>
Annotations:  <none>
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx
  Containers:
   ejercicio2-pod:
    Image:        iesgn/test_web:latest
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  104s  replicaset-controller  Created pod: replicaset-ejercico2-qw7lt
  Normal  SuccessfulCreate  102s  replicaset-controller  Created pod: replicaset-ejercico2-fgfxl
  Normal  SuccessfulCreate  102s  replicaset-controller  Created pod: replicaset-ejercico2-5v8p5
~~~

* Ve los Pods que se han creado, después de eliminar uno de ellos.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/2$ kubectl delete pod replicaset-ejercico2-qw7lt
pod "replicaset-ejercico2-qw7lt" deleted

alejandrogv@AlejandroGV:~/kubernetes/ejercicios/2$ kubectl get pod
NAME                         READY   STATUS    RESTARTS   AGE
pod-ejercicio1               1/1     Running   1          5d23h
replicaset-ejercico2-4v7zn   1/1     Running   0          26s
replicaset-ejercico2-5v8p5   1/1     Running   0          6m58s
replicaset-ejercico2-fgfxl   1/1     Running   0          6m58s
~~~

* Mira los Pods que se han creado después del escalado.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/2$ kubectl scale rs replicaset-ejercico2 --replicas=6
replicaset.apps/replicaset-ejercico2 scaled

alejandrogv@AlejandroGV:~/kubernetes/ejercicios/2$ kubectl get pod
NAME                         READY   STATUS              RESTARTS   AGE
pod-ejercicio1               1/1     Running             1          5d23h
replicaset-ejercico2-4v7zn   1/1     Running             0          3m14s
replicaset-ejercico2-5v8p5   1/1     Running             0          9m46s
replicaset-ejercico2-b9vzz   0/1     ContainerCreating   0          7s
replicaset-ejercico2-dhwqb   0/1     ContainerCreating   0          7s
replicaset-ejercico2-fgfxl   1/1     Running             0          9m46s
replicaset-ejercico2-phd28   0/1     ContainerCreating   0          7s
~~~

### Ejercicio 4

* Vistazo al fichero yaml.

~~~
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dep-ejercicio3
  labels:
    app: nginx
spec:
  revisionHistoryLimit: 2
  strategy:
    type: RollingUpdate
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: iesgn/test_web:latest
        name: cont-ejercicio3
        ports:
        - name: http
          containerPort: 80
~~~

* Ver los recursos que se han creado.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/3$ kubectl get deploy,rs,pod
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/dep-ejercicio3   2/2     2            2           3m58s

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/dep-ejercicio3-5c6c748cfc   2         2         2       3m58s

NAME                                  READY   STATUS    RESTARTS   AGE
pod/dep-ejercicio3-5c6c748cfc-6bccx   1/1     Running   0          3m58s
pod/dep-ejercicio3-5c6c748cfc-z6pcl   1/1     Running   0          3m58s
~~~

* Información detallada del Deployment.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/3$ kubectl describe deploy dep-ejercicio3
Name:                   dep-ejercicio3
Namespace:              default
CreationTimestamp:      Wed, 23 Feb 2022 14:06:36 +0100
Labels:                 app=nginx
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   cont-ejercicio3:
    Image:        iesgn/test_web:latest
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   dep-ejercicio3-5c6c748cfc (2/2 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  5m32s  deployment-controller  Scaled up replica set dep-ejercicio3-5c6c748cfc to 2
~~~

* Acceder desde un navegador web a la aplicación usando el port-forward.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/3$ kubectl port-forward deployment/dep-ejercicio3 8383:80
Forwarding from 127.0.0.1:8383 -> 80
Forwarding from [::1]:8383 -> 80
~~~

![conexión](/ejercicios_kubernetes/2.png)

* Ver los logs del despliegue.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/3$ kubectl logs deployment/dep-ejercicio3
Found 2 pods, using pod/dep-ejercicio3-5c6c748cfc-ntwzd
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
[Wed Feb 23 13:21:41.685021 2022] [mpm_event:notice] [pid 1:tid 140576197522560] AH00489: Apache/2.4.46 (Unix) configured -- resuming normal operations
[Wed Feb 23 13:21:41.685157 2022] [core:notice] [pid 1:tid 140576197522560] AH00094: Command line: 'httpd -D FOREGROUND'
127.0.0.1 - - [23/Feb/2022:13:22:32 +0000] "GET / HTTP/1.1" 200 2884
127.0.0.1 - - [23/Feb/2022:13:22:32 +0000] "GET /favicon.ico HTTP/1.1" 404 196
~~~

### Ejercicio 5

* Pantallazo de la primera version de la aplicación.

![conexión](/ejercicios_kubernetes/3.png)

* Pantallazo de la segunda versión de la aplicación.

![conexión](/ejercicios_kubernetes/4.png)

* Visualizar el historial de actualización del despligue después de actualizar a la versión 2.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/3$ kubectl rollout history deployment/dep-ejercicio3
deployment.apps/dep-ejercicio3 
REVISION  CHANGE-CAUSE
1         Despliegue de la primera version
2         Despliegue de la segunda version
~~~

* Pantallazo de la tercera versión de la aplicación.

![conexión](/ejercicios_kubernetes/5.png)

* Historial despúes de hacer un rollback.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/3$ kubectl rollout history deployment/dep-ejercicio3
deployment.apps/dep-ejercicio3 
REVISION  CHANGE-CAUSE
1         Despliegue de la primera version
3         Despliegue de la version final
4         Despliegue de la segunda version
~~~

* Accediendo a la aplicación después de hacer el rollout.

![conexión](/ejercicios_kubernetes/6.png)

### Ejercicio 6

* Recursos que se crean.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/6$ kubectl get all
NAME                             READY   STATUS              RESTARTS   AGE
pod/guestbook-7cfcc5ff8d-9m5q5   0/1     ContainerCreating   0          9s
pod/guestbook-7cfcc5ff8d-lpmgx   0/1     ContainerCreating   0          10s
pod/guestbook-7cfcc5ff8d-zdcl8   0/1     ContainerCreating   0          9s
pod/redis-5d96fc576-mv4tl        0/1     ContainerCreating   0          4s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   13d

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/guestbook   0/3     3            0           12s
deployment.apps/redis       0/1     1            0           4s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/guestbook-7cfcc5ff8d   3         3         0       12s
replicaset.apps/redis-5d96fc576        1         1         0       4s
~~~

* Acceso desde un navegador web a la aplicación usando el port-forward, y se vea el mensaje de error al no poder acceder a la base de datos.

![conexión](/ejercicios_kubernetes/7.png)

### Ejercicio 7

* Pantallazo donde se vea el acceso desde un navegador web a la aplicación cuando sólo tenemos el servicio para acceder a la aplicación.

![conexión](/ejercicios_kubernetes/8.png)

* Pantallazo donde se vea el acceso desde un navegador web a la aplicación usando la ip del nodo master y el puerto asignado al Service.

![conexión](/ejercicios_kubernetes/9.png)

* Pantallazo donde se vea el acceso desde un navegador web a la aplicación usando el nombre que hemos configurado en el recurso Ingress.

![conexión](/ejercicios_kubernetes/11.png)

### Ejercicio 8

* definición del recurso ConfigMap.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/8$ kubectl describe cm temperaturas
Name:         temperaturas
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
SERVIDOR_TEMPERATURAS:
----
servidor-temperaturas:5000

BinaryData
====

Events:  <none>
~~~

* modificación del fichero frontend-deployment.yaml

~~~
apiVersion: apps/v1
kind: Deployment
metadata:
  name: temperaturas-frontend
  labels:
    app: temperaturas
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: temperaturas
      tier: frontend
  template:
    metadata:
      labels:
        app: temperaturas
        tier: frontend
    spec:
      containers:
      - name: contenedor-temperaturas
        image: iesgn/temperaturas_frontend
        ports:
          - name: http-server
            containerPort: 3000
        env:
          - name: TEMP_SERVERIDOR
            valueFrom:
              configMapKeyRef:
                name: temperaturas
                key: SERVIDOR_TEMPERATURAS
~~~

* modificación del fichero backend-srv.yaml

~~~
apiVersion: v1
kind: Service
metadata:
  name: servidor-temperaturas
  labels:
    app: temperaturas
    tier: backend
spec:
  type: ClusterIP
  ports:
  - port: 5000
    targetPort: api-server
  selector:
    app: temperaturas
    tier: backend
~~~

* Pantallazo de acceso a la aplicación.

![conexión](/ejercicios_kubernetes/12.png)

### Ejercicio 9

* Definición del recurso `PersistentVolumeClaim`

~~~
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: pvc-webserver
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
~~~

* Ver los recursos pv y pvc que se han creado.

~~~
kubectl get pv,pvc
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   REASON   AGE
persistentvolume/pvc-9b2a2a55-897c-4324-a16b-ece4f4a790e2   2Gi        RWO            Delete           Bound    default/pvc-webserver   standard                26s

NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc-webserver   Bound    pvc-9b2a2a55-897c-4324-a16b-ece4f4a790e2   2Gi        RWO            standard       27s
~~~

* Definición del servidor web php.

~~~
apiVersion: apps/v1
kind: Deployment
metadata:
  name: servidorweb
  labels:
    app: apache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apache
  template:
    metadata:
      labels:
        app: apache
    spec:
      volumes:
        - name: volumen-servidorweb
          persistentVolumeClaim:
            claimName: pvc-servidorweb
      containers:
        - name: contenedor-apache-php
          image: php:7.4-apache
          ports:
            - name: http-server
              containerPort: 80
          volumeMounts:
            - mountPath: "/var/www/html"
              name: volumen-servidorweb
~~~

* Pantallazo donde se vea el acceso a `info.php`

![conexión](/ejercicios_kubernetes/13.png)

* Pantallazo donde se vea que se ha eliminado y se ha vuelto a crear el despliegue y se sigue sirviendo el fichero `info.php`

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/9$ kubectl delete deployment.apps/servidorweb
deployment.apps "servidorweb" deleted
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/9$ kubectl apply -f servidor-web.yaml 
deployment.apps/servidorweb created
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/9$ kubectl get all
NAME                               READY   STATUS              RESTARTS   AGE
pod/servidorweb-745bc67f58-f9xx7   0/1     ContainerCreating   0          4s

NAME                           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes             ClusterIP   10.96.0.1       <none>        443/TCP        27d
service/servicio-servidorweb   NodePort    10.110.195.22   <none>        80:32699/TCP   4m11s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/servidorweb   0/1     1            0           5s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/servidorweb-745bc67f58   1         1         0       5s
~~~

![conexión](/ejercicios_kubernetes/13.png)

### Ejercicio 10

* Definición del recurso PersistentVolumenClaim

~~~
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: pvc-redis
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
~~~

* Visualizar los recursos `pv` y `pvc` que se han creado.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/10$ kubectl get pv,pvc
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   REASON   AGE
persistentvolume/pvc-0610bddb-4e9f-4d1e-81df-e1b0244789fb   3Gi        RWO            Delete           Bound    default/pvc-redis   standard                10s

NAME                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc-redis   Bound    pvc-0610bddb-4e9f-4d1e-81df-e1b0244789fb   3Gi        RWO            standard       11s
~~~

* Fichero yaml modificado para el despliegue de redis.

~~~
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: redis
    tier: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
      tier: backend
  template:
    metadata:
      labels:
        app: redis
        tier: backend
    spec:
      volumes:
        - name: volumen-redis
          persistentVolumeClaim:
            claimName: pvc-redis
      containers:
        - name: contenedor-redis
          image: redis
          command: ["redis-server"]
          args: ["--appendonly", "yes"]
          ports:
            - name: redis-server
              containerPort: 6379
          volumeMounts:
            - mountPath: "/data"
              name: volumen-redis
~~~

* Acceso a la aplicación con los mensajes escritos.

![conexión](/ejercicios_kubernetes/14.png)

* Pantallazo donde se vea que se ha eliminado y se ha vuelto a crear el despliegue de redis y que se sigue sirviendo la aplicación con los mensajes.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/10$ kubectl delete deployment redis
deployment.apps "redis" deleted

alejandrogv@AlejandroGV:~/kubernetes/ejercicios/10$ kubectl apply -f redis.yaml 
deployment.apps/redis created
~~~

![conexión](/ejercicios_kubernetes/14.png)

### Ejercicio 11

* búsqueda del chart con el comando `helm`

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/10$ helm search repo wordpress
NAME                   	CHART VERSION	APP VERSION	DESCRIPTION                                       
bitnami/wordpress      	13.0.22      	5.9.1      	WordPress is the world's most popular blogging ...
bitnami/wordpress-intel	0.1.13       	5.9.1      	WordPress for Intel is the most popular bloggin..
~~~

* Pantallazo donde se compruebe que se ha desplegado de forma correcta.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/10$ helm install serverweb bitnami/wordpress --set service.type=NodePort --set wordpressBlogName=alegv    
NAME: serverweb
LAST DEPLOYED: Wed Mar  9 12:27:50 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: wordpress
CHART VERSION: 13.0.22
APP VERSION: 5.9.1

** Please be patient while the chart is being deployed **

Your WordPress site can be accessed through the following DNS name from within your cluster:

    serverweb-wordpress.default.svc.cluster.local (port 80)

To access your WordPress site from outside the cluster follow the steps below:

1. Get the WordPress URL by running these commands:

   export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services serverweb-wordpress)
   export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
   echo "WordPress URL: http://$NODE_IP:$NODE_PORT/"
   echo "WordPress Admin URL: http://$NODE_IP:$NODE_PORT/admin"

2. Open a browser and access WordPress using the obtained URL.

3. Login with the following credentials below to see your blog:

  echo Username: user
  echo Password: $(kubectl get secret --namespace default serverweb-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
~~~

* Visualizar los Pods, ReplicaSets, Deployments y Services que se han creado.

~~~
alejandrogv@AlejandroGV:~/kubernetes/ejercicios/10$ kubectl get all
NAME                                      READY   STATUS    RESTARTS        AGE
pod/serverweb-mariadb-0                   1/1     Running   0               6m34s
pod/serverweb-wordpress-5cdf8f4fc-rd4db   1/1     Running   2 (2m15s ago)   6m35s

NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/kubernetes            ClusterIP   10.96.0.1        <none>        443/TCP                      27d
service/serverweb-mariadb     ClusterIP   10.104.47.63     <none>        3306/TCP                     6m36s
service/serverweb-wordpress   NodePort    10.110.120.241   <none>        80:30920/TCP,443:30735/TCP   6m35s

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/serverweb-wordpress   1/1     1            1           6m35s

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/serverweb-wordpress-5cdf8f4fc   1         1         1       6m35s

NAME                                 READY   AGE
statefulset.apps/serverweb-mariadb   1/1     6m35s
~~~

* Pantallazo donde se vea el acceso al blog y se vea tu nombre como título del blog.

![conexión](/ejercicios_kubernetes/15.png)