+++
title = "Práctica mdadm y rclone"
description = ""
tags = [
    "SAD"
]
date = "2021-03-17"
menu = "main"
+++
# RAID 5

h2. Tarea 1

<pre><code class="shell">
sudo mdadm --create /dev/md5 -l5 -n3 /dev/sdb /dev/sdc /dev/sdd
</code></pre>

h3. Diferencias RAID 1 y RAID 5

* RAID 1:
- Se necesitan mínimo 2 discos
- Se almacenan los datos en modo espejo
- Escritura lenta y lectura rápida

* RAID 5:
- Operaciones rápidas, incluso para varios usuarios simultaneamente.
- Para la tolerancia a fallos usa paridad y suma de verificación.
- Sus datos se almacenan de forma aleatoria por sus diferentes discos al igual que su paridad para su reconstrucción.
- Lectura lenta.
- Requiere mínimo 3 discos.

h2. Tarea 2

* Caracteristicas:
<pre><code class="shell">
sudo mdadm -D /dev/md5
</code></pre>

* Estado: 
<pre><code class="shell">
cat /proc/mdstat
</code></pre>

* Nuestro RAID 5 dispone de 3 GB, sin embargo uno se usa para paridad por lo que útiles tenemos 2 GB para almacenar información.

h2. Tarea 3

* Primero creamos el grupo de volumenes
<pre><code class="shell">
sudo vgcreate raid5 /dev/md5
</code></pre>

* Y seguidamente el volumen lógico
<pre><code class="shell">
sudo lvcreate -L 500M -n disco1 raid5
</code></pre>

h2. Tarea 4 

* Primero debemos instalar este paquete para poder montar en xfs con mkfs
<pre><code class="shell">
sudo apt-get install xfsprogs
</code></pre>

* Y formateamos
<pre><code class="shell">
sudo mkfs.xfs /dev/raid5/disco1
</code></pre>

h2. Tarea 5
<pre><code class="shell">
sudo mount /dev/raid5/disco1 /mnt/raid5
</code></pre>

* Para que este punto de montaje sea permanente necesitamos editar el fichero fstab de la siguiente forma:
<pre>
UUID=ffC3KF-As96-HhdY-fjpD-6TG1-7yjG-ZjitFI /mnt/raid5  xfs     defaults        0       1
</pre>

h2. Tarea 6

* Marcamos uno de los discos como estropeado.
<pre><code class="shell">
sudo mdadm -f /dev/md5 /dev/sdb
</code></pre>

* En la siguiente imagen podemos ver que el el sdb falla.
!2.png!

h2. Tarea 7 

* Retiramos el disco estropeado
<pre><code class="shell">
mdadm --manage /dev/md2 --remove faulty
</code></pre>

h2. Tarea 8 

* Añadimos nuevo dispositivo al raid 5
<pre><code class="shell">
sudo mdadm -a /dev/md5 /dev/sde
</code></pre>

* Vemos que todo vuelve a la normalidad
!3.png!

h2. Tarea 9

* Añadimos otro disco de reserva
<pre><code class="shell">
sudo mdadm -a /dev/md5 /dev/sdf
</code></pre>

* Si marcamos uno como estropeado veremos que inmediatamente el otro se pondra a trabajar.
!4.png!

h2. Tarea 10

* Primero aumentamos de tamaño el volumen lógico y después el sistema de ficheros.
<pre><code class="shell">
sudo lvresize -l +100%FREE /dev/raid5/disco1
sudo xfs_growfs /mnt/raid5/
</pre></code>