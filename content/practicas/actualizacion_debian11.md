+++
title = "Actualización de Debian 10 a Debian 11"
description = ""
tags = [
    "SO"
]
date = "2021-09-16"
menu = "main"
+++

---

### Actualización

* Primero debemos actualizar nuestro debian 10 como tenemos por costumbre hacerlo.

        alejandrogv@AlejandroGV:~$ sudo apt update

        alejandrogv@AlejandroGV:~$ sudo apt upgrade

* Es necesario instalar el paquete gcc-8-base aunque es probable que ya lo tengamos pero nos aseguramos.

        alejandrogv@AlejandroGV:~$ sudo apt install gcc-8-base

* Ahora editamos nuestro `etc/apt/sources.list` para añadir los repositorios del nuevo debian "bullseye"

        deb http://deb.debian.org/debian/ bullseye main contrib non-free
        # deb-src http://deb.debian.org/debian/ buster main
        
        #deb http://security.debian.org/debian-security buster/updates main
        # deb-src http://security.debian.org/debian-security buster/updates main
        
        # buster-updates, previously known as 'volatile'
        deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free
        # deb-src http://deb.debian.org/debian/ buster-updates main
        
        deb http://deb.debian.org/debian/ bullseye-backports main contrib non-free
        # This system was installed using small removable media
        # (e.g. netinst, live or single CD). The matching "deb cdrom"
        # entries were disabled at the end of the installation process.
        # For information about how to configure apt package sources,
        # see the sources.list(5) manual.
        deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main
        # deb-src [arch=amd64] https://packages.microsoft.com/repos/vscode stable main

* Ahora volvemos a actualizar.

        alejandrogv@AlejandroGV:~$ sudo apt clean all

        alejandrogv@AlejandroGV:~$ sudo apt update
        Des:1 http://deb.debian.org/debian bullseye InRelease [113 kB]
        Des:2 http://deb.debian.org/debian bullseye-updates InRelease [36,8 kB]                                 
        Obj:3 http://repository.spotify.com stable InRelease                                                    
        Obj:4 https://download.virtualbox.org/virtualbox/debian buster InRelease                                
        Des:5 http://deb.debian.org/debian bullseye-backports InRelease [40,9 kB]                               
        Des:6 http://deb.debian.org/debian bullseye/main amd64 Packages [8.178 kB]                              
        Obj:7 http://packages.microsoft.com/repos/code stable InRelease                                         
        Obj:8 https://packages.microsoft.com/repos/vscode stable InRelease                                      
        Des:9 http://deb.debian.org/debian bullseye/main Translation-en [6.241 kB]
        Des:10 http://deb.debian.org/debian bullseye/main Translation-es [318 kB]
        Des:11 http://deb.debian.org/debian bullseye/main amd64 DEP-11 Metadata [4.049 kB]
        Des:12 http://deb.debian.org/debian bullseye/main DEP-11 48x48 Icons [3.478 kB]
        Des:13 http://deb.debian.org/debian bullseye/main DEP-11 64x64 Icons [7.315 kB]
        Des:14 http://deb.debian.org/debian bullseye/main all Contents (deb) [30,5 MB]
        Des:15 http://deb.debian.org/debian bullseye/main amd64 Contents (deb) [10,0 MB]                        
        Des:16 http://deb.debian.org/debian bullseye/contrib amd64 Packages [50,4 kB]                           
        Des:17 http://deb.debian.org/debian bullseye/contrib Translation-en [46,9 kB]                           
        Des:18 http://deb.debian.org/debian bullseye/contrib amd64 DEP-11 Metadata [13,6 kB]                    
        Des:19 http://deb.debian.org/debian bullseye/contrib DEP-11 48x48 Icons [47,2 kB]                       
        Des:20 http://deb.debian.org/debian bullseye/contrib DEP-11 64x64 Icons [93,3 kB]                       
        Des:21 http://deb.debian.org/debian bullseye/contrib amd64 Contents (deb) [54,6 kB]                     
        Des:22 http://deb.debian.org/debian bullseye/contrib all Contents (deb) [57,3 kB]                       
        Des:23 http://deb.debian.org/debian bullseye/non-free amd64 Packages [93,8 kB]                          
        Des:24 http://deb.debian.org/debian bullseye/non-free Translation-en [91,5 kB]                          
        Des:25 http://deb.debian.org/debian bullseye/non-free amd64 DEP-11 Metadata [17,9 kB]                   
        Des:26 http://deb.debian.org/debian bullseye/non-free DEP-11 48x48 Icons [741 B]                        
        Des:27 http://deb.debian.org/debian bullseye/non-free DEP-11 64x64 Icons [27,7 kB]                      
        Des:28 http://deb.debian.org/debian bullseye/non-free all Contents (deb) [888 kB]                       
        Des:29 http://deb.debian.org/debian bullseye/non-free amd64 Contents (deb) [75,1 kB]                    
        Des:30 http://deb.debian.org/debian bullseye-backports/main amd64 Packages [68,7 kB]                    
        Des:31 http://deb.debian.org/debian bullseye-backports/main Translation-en [50,5 kB]                    
        Des:32 http://deb.debian.org/debian bullseye-backports/main all Contents (deb) [1.965 kB]               
        Des:33 http://deb.debian.org/debian bullseye-backports/main amd64 Contents (deb) [96,1 kB]              
        Des:34 http://deb.debian.org/debian bullseye-backports/non-free amd64 Packages [1.204 B]                
        Des:35 http://deb.debian.org/debian bullseye-backports/non-free Translation-en [472 B]                  
        Des:36 http://deb.debian.org/debian bullseye-backports/non-free all Contents (deb) [31,5 kB]            
        Descargados 74,1 MB en 16s (4.493 kB/s)                                                                 
        Leyendo lista de paquetes... Hecho
        Creando árbol de dependencias       
        Leyendo la información de estado... Hecho
        Se pueden actualizar 2126 paquetes. Ejecute «apt list --upgradable» para verlos.

* Por último y después de actualizar comprobaremos que nuestro sistema se ha actualizado a debian 11.

        alejandrogv@AlejandroGV:~$ neofetch
               _,met$$$$$gg.          alejandrogv@AlejandroGV 
            ,g$$$$$$$$$$$$$$$P.       ----------------------- 
          ,g$$P"     """Y$$.".        OS: Debian GNU/Linux 11 (bullseye) x86_64 
         ,$$P'              `$$$.     Host: TUF GAMING FX504GD_FX80GD 1.0 
        ',$$P       ,ggs.     `$$b:   Kernel: 5.10.0-8-amd64 
        `d$$'     ,$P"'   .    $$$    Uptime: 4 hours, 20 mins 
         $$P      d$'     ,    $$P    Packages: 2753 (dpkg) 
         $$:      $$.   -    ,d$$'    Shell: bash 5.1.4 
         $$;      Y$b._   _,d$P'      Resolution: 1920x1080 
         Y$$.    `.`"Y$$$$P"'         DE: GNOME 3.38.4 
         `$$b      "-.__              WM: Mutter 
          `Y$$                        WM Theme: Adwaita 
           `Y$$.                      Theme: Adwaita [GTK2/3] 
             `$$b.                    Icons: Adwaita [GTK2/3] 
               `Y$$b.                 Terminal: gnome-terminal 
                  `"Y$b._             CPU: Intel i7-8750H (12) @ 4.100GHz 
                      `"""            GPU: NVIDIA GeForce GTX 1050 Mobile 
                                      GPU: Intel CoffeeLake-H GT2 [UHD Graphics 630] 
                                      Memory: 5034MiB / 7810MiB