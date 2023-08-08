# Implementando Kubernetes en Máquinas Virtuales VMWare con Ubuntu 22.04.

## Creando la Máquina Virtual K8S Master.
|Servidor        |HostName             |CPU          |RAM |IP              | HDD                          | Comentarios      |
|----------------|---------------------|-------------|----|----------------|------------------------------|------------------|
|Master K8s       |k8smaster.k8s.local  |1vCPU 2 Core |4Gb |192.168.123.210 |20GB mínimo( 40Gbrecomendado) |Salida a Internet |

* Ejecutamos VMWare WorkStation
* Menú **File** opción **New Virtual Machine Wizard**
* Seleccionamos la opción **Custom (Advanced)**
	* Presionamos botón **Next**.
* Selecionamos la versión de **Hardware Compatibility** (en este caso estoy trabajando con WorkStation 16.2.x.).
	* Presionamos botón **Next**.
* Buscamos y Seleccionamos la imagen Ubuntu que utilizaremos, en este caso la versión **ubuntu-22.04.2-desktop-amd64.iso**.
	* Presionamos botón **Next**.
* Identificamos la información de la instalación. (Los siguientes valores son recomendaciones)
	* **Full Name:** K8s Master 
	* **User Name:** k8sdevops
	* **Password:** k8sdevops
	* **Confirm:** k8sdevops
	* Presionamos botón **Next**.
* Ingresamos el nombre de la máquina virtual.
	* **Virtual machine name:** K8sMaster
	* **Location**: \VMK8s_Cluster\K8sMaster
	* Presionamos botón **Next**.
* Seleccionamos los siguientes parámetros.
	* **Number of Processors:** 1
	* **Number of cores per processor:** 2
	* Presionamos botón **Next**.
* Seleccionamos **4Gb** o escribimos en **Memory fior this virtual machine:** 4096 **MB**.
	* Presionamos botón **Next**.
* Seleccionamos **Use network address translation (NAT)** .
	* Presionamos botón **Next**.
* Seleccionamos **LSI Logic (Recommended)** .
	* Presionamos botón **Next**.
* Seleccionamos **Use network address translation (NAT)** .
	* Presionamos botón **Next**.
* Seleccionamos **SCSI (Recommended)** .
	* Presionamos botón **Next**.
* Seleccionamos **Create a new virtual disk** .
	* Presionamos botón **Next**.
* Ingresamos **Maximum disk size(Gb):** 40.0.
	* Seleccionamos **Allocate all disk space now**.
	* Seleccionamos **Split virtual disk into multiple files**.
	* Presionamos botón **Next**.
* Asignamos la ruta de disco para la máquina virtual.
	* Buscamos, en **Disk file:** \VMK8s_Cluster\K8sMaster\VirtualDisk
	* Presionamos botón **Next**.
* Ya henos llegado a la parte final para la creación de la máquina virtual.
	* Presionamos botón **Finish**.

>Ahora ha esperar que se cree el disk virtual y el servidor **Ubuntu**. Esto dependiendo de tu notebook o pc o server, alrededor de 5 min.

Una ves iniciado el servidor **Ubuntu**, seleccionar los siguientes parámetros que recomiendo:

* **Keyboard layout**.
	* **Choose your keyboard layout:** Spanish (Latin American).
	* **Spanish (Latin American)**
	* Presionamos botón **Continue**.

* **Updates and Other software**.
	* Seleccionamos **Normal installation**.
	* Seleccionamos **Download updates while installing Ubuntu**
	* Presionamos botón **Continue**.

* **Installation type**.
	* Seleccionamos **Erase disk and install Ubuntu**.
	* Presionamos botón **Install now**.
	* Presionamos botón **Continue**.

* **Who are you?**.
* Identificamos la información del servidor. (Los siguientes valores son recomendaciones)
	* **Your name:** K8s Master 
	* **Your computer's name:** k8smaster.k8s.local
	* **Pick a username:** k8sdevops
	* **Choose a password:** k8sdevops
	* **Confirm your password:** k8sdevops
	* Presionamos botón **Continue**.

Se inicia la instalación de Ubuntu 22.04. Tiempo de espera aproximadamente 5 min.

* **Installation Complete**.
	* Presionamos botón **Restart Now**.
Una vez reiniciada la máquina virtual, seleccione el usuario **K8S Master** e ingrese la clave **k8sdevops** o la ingresada en el momento de la instalación.

Si solicita **Online Account**, presiones **Skip**, **Next**, **Next**, **Next** ,**Done**.

A esta altura estaremos Ok para comenzar a trabajar en nuestra máquina virtual de **Kubernetes Master**

## Comenzamos con la Instalación de Kubernetes.
Ahora comenzaran una serie de comandos que deberás ejecutar para la instalación del Cluster Kubernetes.
>Se profundizaran en algunos comandos Linux para comentar su ejecución, dado que se entiende que es conocedor de este Sistema Operativo.

>Si desea omitir esta serie de comandos, se implemento un Shell Linux que realiza en modo Batch esta instalación con mensajes del proceso que esta ejecutándose (install_k8smaster.sh).

Debemos ingresar a una Terminal.
### 1. Actualizamos el Ubuntu 22.04.

`$ sudo apt update`
`$ sudo apt -y full-upgrade`
`$ sudo reboot -f`

**Esperamos que reinicie la máquina virtual. ingresamos a Linux y abrimos una Terminal.**

### 2. Asignamos la IP Fija a la máquina virtual, en este caso 192.168.123.210.

* Buscamos el aplicativo **Network**.
	* Nos vamos a ruedita de configuración.
	* En los TAB **Wired**, seleccionamos **IPv6** y seleccionamos **Disable** 
	* Vamos al TAB **IPv4** y seleccionamos **Manual** e ingresamos los siguientes parámetros:
		* **Addresses**
			* **Address:** 192.168.123.210
			* **Netmask:** 255.255.255.0
			* **Gateway:** 192.168.123.2 (Esta puede variar según la red a implementar)
		* **DNS:** 192.168.123.220,8.8.8.8,8.8.4.4  (La ip 192.168.123.220, corresponde al DNS k8s, asignar la que posee la organización o localmente. Sino, se creara un DNS local posteriormente en esta implementación)
	* Presionamos botón **Apply**.
	* Apague la **Wired** y vuelva a encender, así nos aseguramos que estamos Ok con la asignación de IP. Este paso es recomendable si esta en un infraestructura propietarias, sino podría perder conectividad con el servidor.

### 3. Asignamos correctamente el nombre del hostname.

`$ sudo hostnamectl set-hostname "k8smaster.k8s.local"`
`$ hostname`

### 4. Editemos el archivo hosts de nuestro Ubuntu *K8smaster*.

`$ sudo vi /etc/hosts`
`192.168.123.220 k8sdns.k8s.local k8sdns`
`192.168.123.210 k8smaster.k8s.local k8smaster`
`192.168.123.212 k8sworked01.k8s.local k8sworked01`

Aunque no existan los demás máquinas virtuales, las dejamos ya creadas. 

Además comentaremos la siguiente línea con un `#`:

`#127.0.1.1      k8smaster.k8s.local      k8smaster`

Grabamos y salimos del editor.

### 5. Deshabilitamos de la máquina virtual el swap o espacio de intercambio.

`$ sudo swapoff -a`
`$ sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab`

Validamos
`$ free -h`

Confirmemos el cambio anterior.

`$ sudo mount -a`
`$ free -h`

### 6. Habilitamos algunos módulos del Kernel Linux.

`$ sudo modprobe overlay`
`$ sudo modprobe br_netfilter`

### 7. Habilitamos algunos opciones del sysctl. Si copia este comando, recomiendo copiar línea a línea.

`$ sudo tee /etc/sysctl.d/kubernetes.conf <<EOF`
```
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

Recargamos el sysctl
`$ sudo sysctl --system`

### 8. Instalación de todos los paquetes necesarios para el Cluster Kubernetes en Ubuntu 22.04.

`$ sudo apt install curl apt-transport-https -y` 
`$ sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates`
`$ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg`
`$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"`
`$ sudo apt update`

**Una buena forma de instalar un Cluster Kubernetes localmente, es utilizando **Containerd**, que es un 
Daemon que nos permite iniciar, crear y ejecutar contenedores basado y creado por **Docker****.

`$ sudo apt install -y containerd.io`
`$ containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1`
`$ sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml`
`$ sudo systemctl restart containerd`
`$ sudo systemctl enable containerd`

**Agregamos el repositorio de Kubernetes.**

`$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg`
`$ sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"`
`$ sudo apt update`

**Instalamos los paquetes **Kubectl**, **Kubeadm** y **Kubelet**.**

`$ sudo apt install -y kubelet kubeadm kubectl`
`$ sudo apt-mark hold kubelet kubeadm kubectl`

**Listo!!.. Terminamos la instalación de paquetes.**

## Iniciamos el Cluster Kubernetes.
Para iniciar el Cluster de Kubernetes necesitamos ejecutar el siguiente comando:

`$ sudo kubeadm init --control-plane-endpoint=k8smaster.k8s.local`

El resultado de este comando, nos entregará unas lista de comandos que debemos ejecutar y el **Token** para integrar en los siguientes pasos las maquinas virtuales **Worked** al **Master**. Por lo cual, guardamos o respaldamos este resultado de comando. En este caso corresponde a:

Los comandos a ejecutar son:

`$ mkdir -p $HOME/.kube`
`$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config`
`$ sudo chown $(id -u):$(id -g) $HOME/.kube/config`

El comando que debemos guardar para los **Worked** es:

`$ kubeadm join k8smaster.k8s.local:6443 --token 5ucnb0.egd4ie1sh8erveob --discovery-token-ca-cert-hash sha256:b556c4ffc46a1187b35f55ba4a06dbd91abd97ad1366b618f199f5614edcd28b`

### Validamos el Cluster Kubernetes en K8s Master.

`$ kubectl cluster-info`
`$ kubectl get nodes`

### Instalando el Plugin de Calico Network.

`$ mkdir ~/calico`
`$ cd ~/calico`

`$ kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml`

`$ kubectl get pods -n kube-system`

`$ kubectl get nodes`
