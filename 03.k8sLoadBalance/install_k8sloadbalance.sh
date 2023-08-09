#install_k8sloadbalance.sh

sudo apt update

sudo apt install wget curl -y

MetalLB_RTAG=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest|grep tag_name|cut -d '"' -f 4|sed 's/v//')

echo $MetalLB_RTAG

mkdir ~/metallb

cd ~/metallb

wget https://raw.githubusercontent.com/metallb/metallb/v$MetalLB_RTAG/config/manifests/metallb-native.yaml

kubectl apply -f metallb-native.yaml

kubectl get pods -n metallb-system

kubectl get all -n metallb-system

tee ~/metallb/ipaddress_pools.yaml<<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: k8s-cluster
  namespace: metallb-system
spec:
  addresses:
  - 192.168.123.230-192.168.123.235
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advert
  namespace: metallb-system
spec:
  ipAddressPools:
  - k8s-cluster
EOF

kubectl apply -f ~/metallb/ipaddress_pools.yaml

kubectl get ipaddresspools.metallb.io  -n metallb-system

kubectl describe ipaddresspools.metallb.io k8s-cluster -n metallb-system
