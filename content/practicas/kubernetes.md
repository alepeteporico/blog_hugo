+++
title = "Kubernetes"
description = ""
tags = [
    "IWEB"
]
date = "2022-06-11"
menu = "main"
+++

* Vamos a instalar la aplicación de bookmedik que instalamos con docker en una prática anterior, esta vez con kubernetes.

## Despliegue en minikube

* Salida de los comando que nos posibilitan ver los recursos que has creado en el cluster.

~~~
alejandrogv@AlejandroGV:~/kubernetes/bookmedik_kubernetes/minikube$ kubectl get pv,pvc
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                              STORAGECLASS   REASON   AGE
persistentvolume/pvc-2b917463-3f4b-4da5-af30-f159dfd61c14   3Gi        RWO            Delete           Bound    default/pvc-bookmedik              standard                40s

NAME                                             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc-bookmedik              Bound    pvc-2b917463-3f4b-4da5-af30-f159dfd61c14   3Gi        RWO            standard       42s


alejandrogv@AlejandroGV:~/kubernetes/bookmedik_kubernetes/minikube$ kubectl get all
NAME                             READY   STATUS    RESTARTS   AGE
pod/bookmedik-5f8c5f6bd7-5rrqc   1/1     Running   0          2m24s
pod/bookmedik-5f8c5f6bd7-l85nv   1/1     Running   0          2m24s
pod/mariadb-7cd5675f98-xv8xc     1/1     Running   0          2m23s

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/bookmedik    NodePort    10.100.132.131   <none>        80:31822/TCP   2m25s
service/kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        124d
service/mariadb      ClusterIP   10.109.1.6       <none>        3306/TCP       2m21s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/bookmedik   2/2     2            2           2m26s
deployment.apps/mariadb     1/1     1            1           2m24s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/bookmedik-5f8c5f6bd7   2         2         2       2m26s
replicaset.apps/mariadb-7cd5675f98     1         1         1       2m24s
~~~

* Pantallazo accediendo a la aplicación utilizando el servicio.

