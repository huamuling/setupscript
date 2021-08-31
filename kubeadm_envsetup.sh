#Disable Firewall
ufw disable

#Disable Swap
swapoff -a; sed -i '/swap/d' /etc/fstab

#Update sysctl settings for Kubernetes networking
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

#Install docker engine
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt-get install -y  docker-ce docker-ce-cli containerd.io

#configure Docker daemon to use systemd for container management, or else kubelet will not able to run , docker default seems to be cgroupfs , kubelet default is systemmd
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

systemctl restart docker

#Kubernetes setup
#Add Apt repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

#install kubernetes component
apt update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
