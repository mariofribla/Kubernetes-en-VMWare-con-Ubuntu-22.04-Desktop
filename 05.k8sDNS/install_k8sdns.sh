#install_k8sdns.sh

sudo apt update

sudo apt -y full-upgrade

sudo reboot -f

sudo hostnamectl set-hostname "k8sdns.k8s.local"

hostname

sudo tee /etc/hosts <<EOF
192.168.123.220 k8sdns.k8s.local k8sdns
EOF

sudo apt install -y bind9

sudo apt install -y dnsutils

sudo tee /etc/bind/named.conf.options <<EOF
        forwarders {
         192.168.123.254;
         8.8.8.8;
         8.8.4.4;
        };
EOF

sudo systemctl restart bind9

sudo systemctl status bind9

sudo tee /etc/bind/named.conf.local <<EOF
zone "k8s.local" {
    type master;
    file "/etc/bind/db.k8s.local";
};
EOF

sudo cp /etc/bind/db.local /etc/bind/db.k8s.local

sudo cat <<EOF > /etc/bind/db.k8s.local
@       IN      SOA     k8s.local. root.k8s.local. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      k8sdns.k8s.local.
@       IN      A       192.168.123.220
@       IN      AAAA    ::1
k8sdns  IN      A       192.168.123.220
EOF

sudo systemctl restart bind9

sudo systemctl status bind9

sudo tee /etc/bind/named.conf.local <<EOF
zone "123.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192";
};
EOF

sudo cp db.127 db.192

sudo cat <<EOF > /etc/bind/db.192
; BIND reverse data file for local 192.168.123.xxx network
$TTL    604800
@       IN      SOA     k8sdns.k8s.local. root.k8s.local. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      k8sdns.
192     IN      PTR     k8sdns.k8s.local.
EOF

sudo systemctl restart bind9

sudo systemctl status bind9

sudo cat <<EOF > /etc/resolv.conf
nameserver 192.168.123.220
options edns0 trust-ad
search k8s.local
EOF

sudo systemctl restart bind9

sudo systemctl status bind9

ping 192.168.123.220

ping k8sdns.k8s.local

dig -x 127.0.0.1

dig -x google.cl

dig -x ubuntu.com

ping k8smaster.k8s.local

ping k8sworked01.k8s.local

sudo tee /etc/bind/db.k8s.local <<EOF
k8smaster       IN      A       192.168.123.210
k8sworked01     IN      A       192.168.123.212
EOF

sudo systemctl restart bind9

sudo systemctl status bind9

ping k8smaster.k8s.local

ping k8sworked01.k8s.local
