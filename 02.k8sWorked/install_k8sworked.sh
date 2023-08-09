#install_k8sworked.sh

sudo apt update

sudo apt -y full-upgrade

sudo reboot -f

sudo hostnamectl set-hostname "k8sworked01.k8s.local"

hostname

sudo tee /etc/hosts <<EOF
192.168.123.220 k8sdns.k8s.local k8sdns
192.168.123.210 k8smaster.k8s.local k8smaster
192.168.123.212 k8sworked01.k8s.local k8sworked01
EOF

sudo swapoff -a

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

free -h

mount -a

free -h

sudo modprobe overlay

sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

sudo apt install curl apt-transport-https -y

sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update

sudo apt install -y containerd.io

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1

sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd

sudo systemctl enable containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg

sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt update

sudo apt install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

sudo kubeadm join k8smaster.k8s.local:6443 --token 5ucnb0.egd4ie1sh8erveob --discovery-token-ca-cert-hash sha256:b556c4ffc46a1187b35f55ba4a06dbd91abd97ad1366b618f199f5614edcd28b


