# Implementando Kubernetes en Máquinas Virtuales VMWare con Ubuntu 22.04.

## Instalando e Integrando con MetalLB en Cluster Kubernetes y Nginx Ingress.

Realice esta instalación en el nodo **K8S Master**, 

```
$ mkdir ~/ingress
$ cd ~/ingress

$ sudo apt update
$ sudo apt install -y wget curl git
```

```
$ controller_tag=$(curl -s https://api.github.com/repos/kubernetes/ingress-nginx/releases/latest | grep tag_name | cut -d '"' -f 4) 
$ wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/${controller_tag}/deploy/static/provider/baremetal/deploy.yaml

$ mv deploy.yaml nginx-ingress-controller-deploy.yaml
```

Desplegamos los manifiestos de Nginx Ingress.

```
$ kubectl apply -f nginx-ingress-controller-deploy.yaml
$ kubectl config set-context --current --namespace=ingress-nginx
```

Validamos el despliegue.

```
$ kubectl get pods -n ingress-nginx
$ kubectl get svc -n ingress-nginx

$ kubectl get service ingress-nginx-controller --namespace=ingress-nginx
```
