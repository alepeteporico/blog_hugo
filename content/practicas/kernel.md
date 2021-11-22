+++
title = "Compilación de un kérnel linux a medida"
description = ""
tags = [
    "ASO"
]
date = "2021-09-17"
menu = "main"
+++

* Vamos a necesitar instalar cierta paquetería como vemos a continuación.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ sudo apt install build-essential qtbase5-dev

* Necesitamos saber que versión del kernel estamos usando.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ uname -r
        5.10.0-8-amd64

* Descargaremos la versión de nuestro kernel desde [la página oficial](https://mirrors.edge.kernel.org/pub/linux/kernel/)

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.tar.gz

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ ls
        linux-5.10.tar.gz

* Descomprimos este archivo y el resultado será una carpeta con muchisima información.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ tar xzvf linux-5.10.tar.gz

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ cd linux-5.10/
        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ ls
        arch   COPYING  Documentation  include  Kbuild   lib          Makefile  README   security  usr
        block  CREDITS  drivers        init     Kconfig  LICENSES     mm        samples  sound     virt
        certs  crypto   fs             ipc      kernel   MAINTAINERS  net       scripts  tools

* Ejecutaremos el comando `make oldconfig` para generar el fichero `.config` donde se especifican todos los módulos entre otra información, nos preguntará sobre algunos si queremos quitarlos o no, nosotros los quitaremos todos.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ make oldconfig

* Vamos a visualizar que módulos hay ahora mismo enlazados estáticamente y dinámicamente.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=y' .config | wc -l
        2186

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=m' .config | wc -l
        3743

* Vemos que tenemos 2185 estáticos y 3743 dinámicos, quitar esto a mano sería un proceso bastante largo, en lugar de ello podemos hacer uso de la herramienta `make localmodconfig` que comprobará que componentes se están usando en nuestro sistema y eliminará el resto. Nuevamente habŕa algunos que nos pregunte especificamente si queremos quitarlos, también los eliminaremos.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ make localmodconfig

* Volvamos a visualizar los módulos activos y comprobaremos que el número ha bajado considerablemente.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=y' .config | wc -l
        1592
        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=m' .config | wc -l
        278

* Para ir quitando los modulos que veamos innecesarios usamos `make xconfig` nos aparecerá una ventana gráfica donde podremos ir quitando módulos desmarcandolos y ahora veremos como compilar este kernel cuando lo veamos necesario. Este proceso lo realizaremos poco a poco, quitaremos algunos módulos, compilaremos y probaremos que el sistema sigue funcionando.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ make xconfig
          UPD     scripts/kconfig/.qconf-cfg
          MOC     scripts/kconfig/qconf.moc
          HOSTCXX scripts/kconfig/qconf.o
          HOSTLD  scripts/kconfig/qconf
        scripts/kconfig/qconf  Kconfig
        Warning: Ignoring XDG_SESSION_TYPE=wayland on Gnome. Use QT_QPA_PLATFORM=wayland to run on Wayland anyway.

![xconfig]()

* Cada vez que realizemos este proceso, sería bueno hacer una copia de seguridad del fichero `.config` antes, así si el sistema no carga correctamente podríamos usar la configuración anterior. Vamos a comprobar el fichero `.config` después de quitar algunos módulos.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=y' .config | wc -l
        1576
        
* Antes de realizar la compilación puede que necesitemos instalar el siguiente paquete:

~~~
alejandrogv@AlejandroGV:~$ sudo apt install dwarves
~~~

* Ahora vamos a compilar este kernel.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ make -j12 bindeb-pkg

* Una vez compilado tendremos como resultado un archivo `.deb`, veamos cuanto pesa para compararlo más adelante con el kernel final.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ ls -lh linux-image-5.10.0_5.10.0-2_amd64.deb 
-rw-r--r-- 1 alejandrogv alejandrogv 13M oct 18 10:44 linux-image-5.10.0_5.10.0-2_amd64.deb
~~~

* Después de haber quitado algunos modulos tenemos un kernel resultante de 9,2 MB ahora solo lo instalariamos con `dpkg -i` y al reiniciar el sistema entramos con el kernel que acabamos de compilar.

* Si queremos ver los kernels que tenemos instalados debemos listar los headers y los image instalados en nuestro sistema

~~~
alejandrogv@AlejandroGV:~$ dpkg --get-selections | grep linux-image
linux-image-5.10.0				install
linux-image-5.10.0-8-amd64			install
linux-image-5.10.0-9-amd64			install
linux-image-amd64				install

alejandrogv@AlejandroGV:~$ dpkg --get-selections | grep linux-headers
linux-headers-5.10.0				install
linux-headers-5.10.0-8-amd64			install
linux-headers-5.10.0-8-common			install
linux-headers-5.10.0-9-amd64			install
linux-headers-5.10.0-9-common			install
linux-headers-amd64				install
~~~

* Y si queremos desinstalar algunos hacemos:

~~~
alejandrogv@AlejandroGV:~$ sudo apt remove --purge linux-image-5.10.0
~~~

* Llegará un momento en que tendremos que desactivar la interfaz gráfica para que funcione nuestro kernel compilado, ya que habremos quitado módulos del entorno gráfico, para hacerlo usamos:

~~~
systemctl set-default multi-user.target
~~~

* Y si queremos volver a activarlo:

~~~
systemctl set-default graphical.target
~~~

* Después de varias pruebas tenemos nuestro kernel compilado lo mas simple posible, vamos a contar nuevamente los módulos del fichero `.config`

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=y' .config | wc -l
        713
        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel/linux-5.10$ egrep '=m' .config | wc -l
        103

* Si vemos también el kernel compilado como vimos anteriormente, notaremos que pesa bastante menos, en concreto 8 MB menos.     

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/sistemas/kernel$ ls -lh linux-image-4.19.16_4.19.16-1_amd64.deb 
        -rw-r--r--  1 alejandrogv alejandrogv 5,2M nov 21 21:43 linux-image-5.10.0_5.10.0-38_amd64.deb

* Estos son todos los modulos que he quitado:

~~~
* General setup
 - System V IPC
 - POSIX Message Queues
 - Enable process_vm_readv/writev syscalls
 - Auditing support
 - Support for paging of anonymus memory
 - CPU isolation
 - Memory placement aware NUMA scheluder
 - Checkpoint/restore Support
 - Automatic process group scheduling
 - Inlclude all symbols in kallsyms
 - LSM Instrumentation with BPF
 - Enable bpf() system call
 - Enable userfaultfd() system call
 - Enable rseq() system call
 - Enable VM event counters for /proc/vmstat
 - Enable SLUB debugging support
 - Allow slab caches to be merged
 - Randomize slab freelist
 - Harden slab freelist metadata
 - Page allocator randomization
 - Profiling support

 + Timers subsystem
  - High Resolution Timer Support.
 + CPU/Task time and stats accounting.
  - Export task/process statistics through netlink
  - Pressure stall information tracking

 + Namespaces support
  - UTS Namespaces
  - Time Namespaces
  - IPC Namespaces
  - User Namespaces
  - PID Namespaces
  - Network Namespaces

 + Configure standard kernel features

* Processor type and features
  - Reroute for broken boot IRQs
  - Symmetric multi-processing support
  - Support x2apic
  - Enable MPS table
  - Avoid speculative indirect branches in kernel
  - x86 CPU resource control support
  - Intel Low Power subsystem support
  - AMD ACPI2Platform devices support
  - Single-depth WCHAN output
  - Old AMD GART IOMMU support
  - Reroute for broken boot IRQs
  - Machine Check / overheating reporting
  - CPU microcode loading support
  - MTRR cleanup support
  - Memory Protection Keys
  - kernel crash dumps
  - Randomize the address of the kernel image (KASLR)

 + Linux guest support

+ Performance monitoring
  - Intel uncore Performance events (M)
  - Intel/AMD rapl Performance events (M)
  - Intel cstate Performance events (M)

* Power management and ACPI options
  - Supend to RAM and standby
  - Device power management core functionality

 + ACPI (Advanced Configuration and Power Interface) Support
 + CPU Frequiency scaling
 + CPU idle PM support

* BUS options (PCI etc.)
  - Support mmconfig PCI config space access

* Binary Emulations
  - IA32 Emulation
  - x32 ABI for 64-bit mode

* Firmware Drivers
  - Export DMI identification via sysfs to userspace
  - DMI table support in sysfs

 + Virtualization

* General architecture-dependent options
  - Kprobes
  - Optimize very unlikely/likely branches
  - Enable seccomp to safely execute untrusted bytecode
  - Stack Protector buffer overflow detection
  - Provide system calls for 32-bit time_t
  - Use a virtually-mapped Stack

 + Enable loadable module support
   - Forced module loading
   - Forced module unloading
   - Module versioning support

* Enable the block layer
  - Block layer SG support v4
  - Block layer SG support v4 helper lib
  - Block layer data integrity support
  - Zoned block device support
  - Block layer bio throttling support
  - Enable support for block device writeback throttling
  - Enable support for cost model based crgroup IO controller
  - Block layer debugging information in debugfs
  - Logic for interfacing with OPal enabled SEDs

  + Partition Types
   - Acorn partition support
   - Alpha OSF partition support
   - Amiga partition table support
   - Atari partition table support
   - Macintosh Partition map support
   - Solaris (x86) partition table support
   - SGI partition support
   - Ultrix partition table support
   - SUN partition table support
   - Karma partition table support
  
  + Memory Management options
   - Sparse Memory virtual memmap
   - Free page reporting
   - Enable bounce buffers
   - Enable KSM for page merging
   - Transparent Hugepage Support
   - Commom API for compressed memory storage
   - Low (Up to 2x) density storage for compressed pages

* Networking support
  - Execute BPF program as route nexthop action
  - Netlink interface for ethtool

  + Networking options
   - 802.1d Ethernet Bridging
   - Data Center Bridging support
   - Switch (and switch-ish) device support
   - L3 Master device support

   + Network packet filtering framework (Netfilter)
    - Advanced netfilter Configuration
  
   + Core Netfilter Configuration
    - Supply CT list in procfs (OBSOLETE)
  
   + Amateur Radio support

   + Bluetooth subsystem support

  + Wireless
   - todo

* Device Drivers
  + PCI support
    - PCI Express Hotplug driver
    - PCI Express Advanced Error reporting support
    - PCI Express Precision Time Measurement support
    - Message Signaled Interrupts (MSI and MSI-X)
    
    + Support for PCI Hotplug

  + Generic Driver options
    - Select only drivers that don't need compile-time external Firmware
    - Disable drivers features which enable custom firmware building

  + Conector unified userspace <_> kernelspace linker
    - Report process events to userspace

  + Misc devices
    - Intel HDCP2.2 services of ME interface
  
    + EEPROM support
      - SPD EEPROMs on DDR4 memory modules
  
  + SCSI device support
    - SCSI CDROM support

    + Fusion MPT device support
    
    + Macintosh device drivers

  + Network device support
    - Fibre Channel driver support
    - FDDI driver support
    - HIPPI driver support

  + Ethernet driver support
    - 3Com devices
    - Adaptec devices
    - Agere devices
    - Alacritech devices
    - Alteon devices
    - AMD devices
    - Amazon devices
    - aQuantia devices
    - Atheros devices
    - Broadcom devices
    - QLogic BR-series devices
    - Cadence devices
    - Cavium ethernet drivers
    - Chelsio devices
    - Cisco devices
    - Cortina Gemini devices
    - Emulex devices
    - EZchip devices
    - Google devices
    - Huawei devices
    - Marvell devices
    - Mellanox devices
    - Micrel devices
    - Microsemi devices
    - Myricom devices
    - Neterion (Exar) devices
    - Netronome(R) devices
    - NVIDIA devices
    - Pensando devices
    - Renesas devices
    - Rocker devices
    - Samsung Ethernet devices
    - Solarflare devices
    - Silan devices
    - Sun devices
    - Synopsys devices
    - Tehuti devices
    - Texas Instruments (TI) devices
    - VIA devices
    - WIZnet devices
    - Xilinx devices
  
  + PHY Device support and infrastructure
    - Support LED triggers for tracking link state
  
  + Wireless LAN
  + WAN interfaces support
  + ISDN support

  + Input device support
    - Export input device LEDs in sysfs
    - Mouse interface
    - Joystick interface
    - Mice 
    - Joysticks/Gamepads
    - Tablets
    - Touchscreens
    - Miscellaneous devices

  + Character devices
    - Automatically load TTY Line Disciplines
    - Serial Drivers
      - Support for Fintek F(1216A to 4 UASRT RS485 API
      - Extended 8250/16550 serial driver options
      - Support for Synopsys DesignWare 8250 quirks
      - Support for serial ports on intel MID platforms
    - Parallel printer support
    - Support for user-space Parallel port device drivers
    - Device interface for IPMI
    - /dev/port character device

    + Serial device BUS
    + IPMI top-level message handler
    + TPM hardware support
  
  + I2C support
    - Enable compatibility bits for old user-space
    - I2C hardware Bus support
      - Synopsys DesignWare platform
    - SPI support
    - Pin controllers
    - GPIO Support

  + Hadware monitoring support
  + Thermal drivers
  + Watchdog timer Support

  + Multifunction device drivers
    - Intel ICH LPC
    - Intel Low Power subsystem support in PCI mode
    - System Controller Register R/W Based on Regmap
  
  + Voltaje and current Regulator Support
  + HDMI CEC drivers
  + Multimedia support

  + Graphics support
    - Enable capturing GPU state following a hang
    - Always enbale userptr support
    - #Enable Intel GVT-g graphics Virtualization host support
    
    + /dev/agpgart (AGP Support)
      - AMD Opteron/Athlon64 on CPU GART support
      - SiS chipset support
      - VIA chipset support

    + Direct Rendering Manager (XFree86 4.1.0 and higher...)
      - Enable DisplayPort CEC-Tunneling-over-AUX HDMI support
    
    + Support for frame buffer devices
      - Enable firmware EDID
      - Enable tile blitting Support

  + Sound card support
  + USB support
  + LED Support
  + Accesibility support
  + EDAC (Error Detection And Correction) reporting
  + Real Time Clock
  + DMA Engine support
  + Virtualization drivers
  + Virtio drivers
  + VHOST drivers
  + Staging drivers
  + X86 platform Specific Device Drivers
  + Platform support for Chrome hardware
  + Mailbox Hardware
  + IOMMU Hardware Support
  + Pulse-Width Modulation (PWM) Support
  + Reset controller Support
  + PHY subsystem
   - PHY Core

  + Generic powercap sysfs driver
  + Reliability, Availability and Serviceability (RAS) features
  + Android
   - Android Drivers
  
  + NVMEM Support

* File systems
  - Quota support

  + Pseudo filesystems
    - Inlclude /proc/<pid>/task7<tid>/children File
    - Tmpfs POSIX Access Control Lists
    - HugeTLB file system support
  
  + Miscellaneous filesystems
  + Network File systems

* Security options
  - Enable reguster of peresistent per-UID keyrings
  - Diffie-Hellman operations on retained Keys
  - Restrict unprivileged access to the kernel syslog
  - Enable different security models
  - Enable the securityfs filesystem
  - Remove the kernel mapping in user mode
  - Harden memory copies between kernel and userspace
  - Harden common str/mem functions against buffer overflows

  + Memory initializarion
   - Enable heap memory zeroing on allocation by default

* Cryptographic API
  - FIPS 200 compliance
  - Diffie-Hellman algorithm
  - ECDH algorithm
  - CCM support
  - GCM/GMAC support
  - CMAC support
  - CRC32c INTEL hardware acceleration
  - CRC32 PCLMULQDQ hardware acceleration
  - CRCT10DIF PCLMULQDQ hardware acceleration
  - GHASH hash funcion (CLMUL-NI accelerated)
  - AES cpher algorithms (AES-NI)

  + NIST SP800-90A DRBG
  + Hardware crypto devices
  + Asymmetric (public-key Cryptographic) key type
    - Support for PE file signature verification
  + Certificates for signature checking
    - Provide a keyring to wich extra trustable keys may be added
    - Provide system-wide ring of blacklisted keys

* Library routines
  - IRQ polling library 
  - Select compiled-in fonts
  - Terminus 16x32 font (not supported by all drivers)

* Kernel hacking
  - Kernel debugging
  - Filter access to /dev/mem

  + printk and dmesg options
    - Show timing information on printks
    - Enable dynamic printk() support
    - Enable core function of dynamic debug support
    - Support symbolic error names in printf

  + Compile-time checks and compiler options
    - Enable __must_check_logic
    - Strip assembler-generated symbols during link
  
  + Generic Kernel Debugging Instruments
    - Magic SysRq key
 
  + Memory debugging
    - Extend memmap on extra space for more information on page
    - Poison pages after freeing
    - Warn on W+Z mappings at boot

  + Debug kernel data structures
    - trigger a BUG when data corruption is detected
  
  + Tracers

  + Kernel Testing and Coverage
    - Memtest
  
  + RUntime Testing
~~~