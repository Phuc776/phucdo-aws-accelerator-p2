#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

APP_NAME="${app_name}"
APP_PORT="${app_port}"
NODE_PORT="${node_port}"
IMAGE_URI="${image_uri}"
AWS_REGION="${aws_region}"

LOG_FILE="/var/log/minikube-install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https unzip

# Install / enable SSM Agent
snap install amazon-ssm-agent --classic || true
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service || true

# Install Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# Install kubectl
curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube /usr/local/bin/minikube

# Start minikube as ubuntu user
sudo -u ubuntu -i minikube start --driver=docker --memory=1800mb --cpus=2 --ports=${node_port}:${node_port}

# Login ECR
aws ecr get-login-password --region "$AWS_REGION" | sudo -u ubuntu -i bash -c "eval \$(minikube docker-env) && docker login --username AWS --password-stdin $(echo "$IMAGE_URI" | cut -d/ -f1)"

# Pull image into minikube docker daemon
sudo -u ubuntu -i bash -c "eval \$(minikube docker-env) && docker pull $IMAGE_URI"

# Create Kubernetes manifests
cat > /home/ubuntu/deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${app_name}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${app_name}
  template:
    metadata:
      labels:
        app: ${app_name}
    spec:
      containers:
      - name: ${app_name}
        image: ${image_uri}
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: ${app_port}
EOF

cat > /home/ubuntu/service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${app_name}
spec:
  type: NodePort
  selector:
    app: ${app_name}
  ports:
  - port: ${app_port}
    targetPort: ${app_port}
    nodePort: ${node_port}
EOF

chown ubuntu:ubuntu /home/ubuntu/deployment.yaml /home/ubuntu/service.yaml

# Deploy app
sudo -u ubuntu -i kubectl apply -f /home/ubuntu/deployment.yaml
sudo -u ubuntu -i kubectl apply -f /home/ubuntu/service.yaml

# Wait and verify
sudo -u ubuntu -i kubectl rollout status deployment/${app_name} --timeout=180s
sudo -u ubuntu -i kubectl get pods -o wide
sudo -u ubuntu -i kubectl get svc

# Local test from EC2
curl -f http://127.0.0.1:${node_port}/status/health || true