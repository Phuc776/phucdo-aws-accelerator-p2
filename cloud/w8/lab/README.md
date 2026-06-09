# Terraform Lab – EC2 + Minikube + FastAPI + ALB

## Overview

Mục tiêu của lab là triển khai một ứng dụng FastAPI chạy trong Kubernetes (Minikube) trên EC2 và expose ra Internet thông qua Application Load Balancer (ALB).

Toàn bộ hạ tầng được dựng bằng Terraform với cơ chế one-click deployment.

---

## Architecture

```text
Internet / Browser
        |
        v
Application Load Balancer :80
        |
        v
Target Group
        |
        v
EC2 Instance :30080
        |
        v
Minikube Cluster
        |
        v
Kubernetes Service (NodePort)
        |
        v
FastAPI Pod
```

Chi tiết luồng request:

```text
Browser
↓
ALB :80
↓
Target Group
↓
EC2 :30080
↓
NodePort Service
↓
FastAPI Container :8000
```

### Architecture Diagram

![Architecture Diagram](images/architecture-diagram.png)

---

## Terraform Providers

Lab sử dụng 2 Terraform providers.

### AWS Provider

AWS Provider chịu trách nhiệm tạo và quản lý toàn bộ hạ tầng cloud:

* ECR Repository
* IAM Role
* IAM Instance Profile
* Security Groups
* EC2 Instance
* Application Load Balancer
* Target Group
* Listener

### Null Provider

Null Provider được sử dụng để thực hiện bước build và push Docker image trước khi EC2 được khởi tạo.

Flow:

```text
Terraform
↓
Create ECR
↓
null_resource
 ├─ docker build
 ├─ docker tag
 └─ docker push
↓
Create EC2
↓
Minikube pulls image from ECR
```

Điều này đảm bảo image đã tồn tại trong ECR trước khi Minikube deploy ứng dụng.

---

## Repository Structure

```text
lab/
├── python-app/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
│
└── terraform/
    ├── provider.tf
    ├── alb.tf
    ├── ec2.tf
    ├── ecr.tf
    ├── variables.tf
    └── userdata/
        └── install.sh
```

---

## Deployment

### Prerequisites

* Terraform >= 1.5
* AWS CLI
* Docker
* AWS credentials configured

### Initialize Terraform

```bash
terraform init
```

### Review Plan

```bash
terraform plan
```

### Deploy Infrastructure

```bash
terraform apply -auto-approve
```

### Terraform Output

```bash
terraform output
```

Ví dụ:

```text
alb_dns_name
ec2_public_ip
ecr_image_uri
```

### Evidence – Terraform Output

![Terraform Output](images/terraform-output.png)

---


### Evidence – Browser Access Through ALB

![ALB Browser Access](images/alb-browser-access.png)

---


### Verify EC2 Instance

```bash
hostname
```

hoặc

```bash
curl http://169.254.169.254/latest/meta-data/instance-id
```

### Evidence – EC2 Verification

![EC2 Verification](images/ec2-verification.png)

---

### Verify Minikube

```bash
minikube status
```

![Verify Minikube](images/verify-minikube.png)


### Verify Deployment

```bash
kubectl get deployment
```

### Verify Pods

```bash
kubectl get pods -o wide
```

### Evidence – Kubernetes Pods

![Kubernetes Pods](images/kubernetes-pods.png)

---

### Verify Service

```bash
kubectl get svc
```

### Evidence – Kubernetes Service

![Kubernetes Service](images/kubernetes-service.png)

---

### Evidence – Target Group Health

![Target Group Healthy](images/target-group-health.png)

---

## Design Decisions

### Why Minikube?

* Lightweight
* Easy bootstrap using EC2 user_data
* Suitable for single-node Kubernetes lab environments

### Why ALB?

* Native AWS service
* Built-in health checks
* Routes Internet traffic to Kubernetes NodePort

### Why ECR?

* Centralized Docker image registry
* EC2 pulls image through IAM Role permissions
* Reusable image for redeployment

### Why Null Provider?

Yêu cầu bài lab là one-click deployment và >=2 providers.

Null Provider được dùng để build và push Docker image lên ECR trước khi EC2 khởi tạo.

Điều này đảm bảo image đã tồn tại trong registry trước khi Minikube bắt đầu deploy ứng dụng.

Trong môi trường production, bước build/push image nên được chuyển sang CI/CD pipeline (GitHub Actions, GitLab CI hoặc Jenkins), còn Terraform chỉ nên quản lý hạ tầng.

---

## Cleanup

Sau khi hoàn tất:

```bash
terraform destroy -auto-approve
```

Lệnh này sẽ xóa:

* ALB
* Target Group
* EC2
* Security Groups
* IAM Role
* IAM Instance Profile
* ECR Repository

### Evidence – Successful Destroy

![Terraform Destroy](images/terraform-destroy.png)

Điều này giúp tránh phát sinh chi phí AWS ngoài ý muốn.
