# Implementando Kubernetes en Máquinas Virtuales VMWare con Ubuntu 22.04.

## Instalando Balanceador de Carga MetalLB en Cluster Kubernetes.
Realice esta instalación en el nodo **K8S Master**.

MetalLB, es un programa que nos apoya para la implementación de un Balanceador de Carga en el Cluster de Kubernetes, siempre y cuando este cluster no se implemente en la Nube o tengo implementado en la red privada un Balanceador.

MetalLB, nos apoya en poder crear servicios Kubernetes tipo **LoadBalancer** y ser expuestos para solicitudes externas.


**Nota:** La instalación se realiza en el nodo **K8S Master**. No aplicar a los nodos Worked.

### 1. Instalación de paquetes necesarios.
Realice esta instalación en el nodo **K8S Master**

Instalamos los siguientes paquetes:

```
sudo apt update
```

Validamos que estén instalado estos paquetes.

```
sudo apt install wget curl -y
```

### 2. Descargamos el manifiesto e instalamos MetalLB.

```
$ MetalLB_RTAG=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest|grep tag_name|cut -d '"' -f 4|sed 's/v//')
$ echo $MetalLB_RTAG
```
```
$ mkdir ~/metallb
$ cd ~/metallb

$ wget https://raw.githubusercontent.com/metallb/metallb/v$MetalLB_RTAG/config/manifests/metallb-native.yaml
```

Desplegamos en el Cluster MetalLB.

```
$ kubectl apply -f metallb-native.yaml
```

Validamos el Despliegue.

```
$ kubectl get pods -n metallb-system
$ kubectl get all -n metallb-system
```


**Para que funcione correctamente MetalLB, tendremos que definir un IP o un rango de IP's para su asignación al Cluster.**

Para esto debemos crear un manifiesto con la siguiente estructura:

```
$ vi ~/metallb/ipaddress_pools.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: k8s-cluster   #Este Nombre definir el rango de IP que se asigmaran posteriomente.
  namespace: metallb-system
spec:
  addresses:
  - 192.168.123.230-192.168.123.235  #Valores referenciales, asigne es que estime.
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advert
  namespace: metallb-system
spec:
  ipAddressPools:
  - k8s-cluster
```

Desplegamos el archivo manifiesto.

```
$ kubectl apply -f ~/metallb/ipaddress_pools.yaml
```

Validamos el despliegue realizado.

```
$ kubectl get ipaddresspools.metallb.io  -n metallb-system
$ kubectl describe ipaddresspools.metallb.io k8s-cluster -n metallb-system
```

**Adicionalmente, podemos mencionar sobre la asignación de IP's las siguientes formas:**

Las direcciones IP se pueden definir por **CIDR** , **por rango** , y se pueden asignar **direcciones IPV4 e IPV6 .**

```
...
spec:
  addresses:
  - 192.168.123.0/24 
```
```
...
spec:
  addresses:
  - 192.168.123.0/24
  - 172.10.10.10-172.10.10.20
  - fc11:f883:0ddd:e788::/124
```

Cada mencionar también, que **name: k8s-cluster**, es un nombre único para un rango de IP's. Por lo cual, si queremos tener rangos distintos deberíamos definir **IPAddressPool** con distintos rangos y posteriormente asignar el despliegue a uno de estos rangos con la **annotations: metallb.universe.tf/address-pool: k8s-dev** en el manifiesto del **Deployment**.
