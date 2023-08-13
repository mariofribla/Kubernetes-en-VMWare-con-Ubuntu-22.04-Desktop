# Implementando Kubernetes en Máquinas Virtuales VMWare con Ubuntu 22.04.

## Instalando Metrics Server en el Cluster Kubernetes

Metrics Server, es un contenedor que nos permite ver las métricas de modo eficiente de Kubernetes.

Entre las métricas podemos ver algunas como:

Bueno, vamos a su instalación que es super sencilla y aporta realmente a la administración de recursos del Cluster Kubernetes.

## Comenzamos con la instalación de Metrics Server.

**Para esto nos conectamos al K8S Master.**

Descargamos el manifiesto de este contenedor.

```
$ mkdir ~/metrics
$ cd ~/metrics

$ curl -LO https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Descargue la siguiente versión si desea que **Metrics Server** este en Alta Disponibilidad. Para esta instalación no aplicaremos esta manifiesto, pero los cambios que se mencionaran aplica para ambos archivos.

```
$ curl https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml
```

Editamos el archivo **components.yaml** para agregar algunos parámetros necesarios para su funcionamiento.

```
$ vi components.yaml 
```

En las líneas 196 del archivo **componenys.yaml**, configure como se indica a continuación, agregue estos 2 parámetros necesarios para su funcionamiento como se indica texto posterior.

* hostNetwork: true  (Línea 197)
* kubelet-insecure-tls  (Línea 205)

```
196    spec:
197      hostNetwork: true
198      containers:
199      - args:
200        - --cert-dir=/tmp
201        - --secure-port=4443
202        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
203        - --kubelet-use-node-status-port
204        - --metric-resolution=15s
205        - --kubelet-insecure-tls
206        image: registry.k8s.io/metrics-server/metrics-server:v0.6.4
```

A continuación desplegamos Metrics Server.

```
$ kubectl apply -f components.yaml
```

Validamos su despliegue.

```
$ kubectl get pods -n kube-system 

NAME                                          READY   STATUS    RESTARTS      AGE
calico-kube-controllers-6c99c8747f-x8h5j      1/1     Running   4 (51m ago)   5d18h
calico-node-bm28x                             1/1     Running   4 (51m ago)   5d18h
calico-node-gklv6                             1/1     Running   4 (51m ago)   5d18h
coredns-5d78c9869d-cqk9g                      1/1     Running   4 (51m ago)   5d23h
coredns-5d78c9869d-xv28b                      1/1     Running   4 (51m ago)   5d23h
etcd-k8smaster.k8s.local                      1/1     Running   5 (51m ago)   5d23h
kube-apiserver-k8smaster.k8s.local            1/1     Running   5 (51m ago)   5d23h
kube-controller-manager-k8smaster.k8s.local   1/1     Running   5 (51m ago)   5d23h
kube-proxy-px47v                              1/1     Running   5 (51m ago)   5d23h
kube-proxy-w5gk2                              1/1     Running   5 (51m ago)   5d21h
kube-scheduler-k8smaster.k8s.local            1/1     Running   5 (51m ago)   5d23h
metrics-server-6b4694c468-cms4b               1/1     Running   0             41s
```

 En mi Cluster Kubernetes se visualiza que esta en ejecución.

**metrics-server-6b4694c468-cms4b               1/1     Running   0             41s**

Veamos algunos comandos:

```
$ kubectl top nodes

AME                    CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8smaster.k8s.local     220m         11%    2853Mi          75%       
k8sworked01.k8s.local   95m          4%     1488Mi          39%  
```

```
$ kubectl top pod

NAME                                        CPU(cores)   MEMORY(bytes)   
ingress-nginx-controller-5c778bffff-wt4z8   1m           98Mi

```

```
$ kubectl top pod -n app-ejemplo

NAME          CPU(cores)   MEMORY(bytes)   
app-ejemplo   1m           1Mi   
```

```
$ kubectl top pod -n kube-system

NAME                                          CPU(cores)   MEMORY(bytes)   
calico-kube-controllers-6c99c8747f-x8h5j      3m           25Mi            
calico-node-bm28x                             48m          89Mi            
calico-node-gklv6                             40m          90Mi            
coredns-5d78c9869d-cqk9g                      3m           22Mi            
coredns-5d78c9869d-xv28b                      3m           23Mi            
etcd-k8smaster.k8s.local                      31m          97Mi            
kube-apiserver-k8smaster.k8s.local            53m          340Mi           
kube-controller-manager-k8smaster.k8s.local   22m          64Mi            
kube-proxy-px47v                              1m           27Mi            
kube-proxy-w5gk2                              1m           14Mi            
kube-scheduler-k8smaster.k8s.local            5m           29Mi            
metrics-server-6b4694c468-cms4b               5m           15Mi 
```

```
$ kubectl top 

Display Resource (CPU/Memory) usage.
 The top command allows you to see the resource consumption for nodes or pods.
 This command requires Metrics Server to be correctly configured and working on the server.
Available Commands:
  node          Display resource (CPU/memory) usage of nodes
  pod           Display resource (CPU/memory) usage of pods
Usage:
  kubectl top [flags] [options]
Use "kubectl <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
```

Bueno, que disfruten este despliegue.


