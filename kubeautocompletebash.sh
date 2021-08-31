apt-get install bash-completion
echo "source /usr/share/bash-completion/bash_completion" >> ~/.bashrc
exec bash
#type _init_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
systemctl restart kubelet.service
exec bash

