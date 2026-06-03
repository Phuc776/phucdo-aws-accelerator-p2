# W8 Reflection

## Day 1

### Infrastructure as Code (IaC)

IaC (Infrastructure as Code) là cách mô tả và quản lý hạ tầng bằng mã nguồn thay vì thao tác thủ công trên giao diện quản trị.

Triết lý của IaC là toàn bộ hạ tầng có thể được định nghĩa, triển khai và tái tạo thông qua code. Điều này giúp đảm bảo tính nhất quán giữa các môi trường Dev, Test, Staging và Production, đồng thời cho phép quản lý thay đổi bằng Git giống như phát triển phần mềm.

### Một số công cụ liên quan

* Terraform
* OpenTofu
* AWS CloudFormation
* Pulumi
* Ansible (thiên về Configuration Management và Automation)

---

## Thực hành hôm nay

### Cài đặt môi trường

* Cài đặt Terraform trên Windows bằng Chocolatey
* Kiểm tra version thành công bằng:

```powershell
terraform -v
```

* Đã cấu hình và kiểm tra Docker Desktop hoạt động bình thường

### Terraform cơ bản

Thực hiện cấu hình đơn giản sử dụng:

* terraform block
* locals
* output

Ví dụ:

```hcl
locals {
  name = "hello-terraform"
}

output "message" {
  value = local.name
}
```

Đã chạy thành công:

```powershell
terraform init
terraform plan
```

Kết quả:

```text
message = "hello-terraform"
```

### Terraform với Docker Provider

Thực hiện triển khai hạ tầng local bằng Terraform thông qua Docker Provider.

Các resource được tạo:

* docker_image.nginx
* docker_container.nginx

Container được expose:

```text
localhost:8080 -> nginx:80
```

Thực hiện đầy đủ vòng đời:

```powershell
terraform init
terraform plan
terraform apply
terraform destroy
```

Kết quả:

* Terraform pull image nginx:alpine
* Terraform tạo container nginx
* Truy cập thành công thông qua http://localhost:8080
* Terraform destroy xóa toàn bộ tài nguyên đã tạo

### Terraform với AWS Provider

Đã kiểm tra và xác nhận Terraform có thể kết nối AWS account cá nhân.

Thực hiện tạo và xóa tài nguyên AWS thành công bằng Terraform.

Thông qua quá trình này đã quan sát được cách Terraform:

* So sánh cấu hình mong muốn với trạng thái hiện tại
* Sinh execution plan
* Áp dụng thay đổi lên hạ tầng thực tế
* Cập nhật Terraform State

---

## Điều học được

Terraform hoạt động theo mô hình:

Configuration (.tf)
→ Provider
→ Plan
→ Apply
→ State

Terraform không trực tiếp quản lý hạ tầng mà sử dụng Provider để giao tiếp với nền tảng đích như AWS, Azure, GCP hoặc Docker.

### Terraform State

Một trong những khái niệm quan trọng nhất là Terraform State.

Sau khi apply, Terraform tạo file:

```text
terraform.tfstate
```

State đóng vai trò là nguồn dữ liệu lưu lại:

* Resource nào đang được Terraform quản lý
* ID của resource
* Metadata liên quan
* Outputs

Terraform sử dụng State để xác định sự khác biệt giữa:

```text
Infrastructure thực tế
vs
Infrastructure được mô tả trong code
```

### Các file được Terraform sinh ra

#### .terraform/

Được tạo bởi:

```powershell
terraform init
```

Chứa provider và plugin đã được tải về.

#### .terraform.lock.hcl

Chứa version provider được khóa lại để đảm bảo môi trường nhất quán giữa các máy.

#### terraform.tfstate

Lưu trạng thái hiện tại của hạ tầng mà Terraform đang quản lý.

#### terraform.tfstate.backup

Bản backup của state trước lần thay đổi gần nhất.

---

## So sánh với trải nghiệm AWS Accelerator Phase 1

Trong Phase 1, phần lớn hạ tầng được tạo trực tiếp thông qua AWS Console hoặc CLI.

Terraform cung cấp một cách tiếp cận khác:

* Hạ tầng được mô tả dưới dạng code
* Có thể review qua Git
* Có thể tái sử dụng nhiều lần
* Có thể tái tạo toàn bộ môi trường khi cần
* Giảm sai sót do cấu hình thủ công

Điều này giúp hạ tầng được quản lý giống như một sản phẩm phần mềm thay vì một tập hợp các thao tác thủ công trên giao diện quản trị.

---

## Kế hoạch tiếp theo

* Tìm hiểu sâu hơn về Provider và Resource
* Variables và Outputs
* Terraform State Management
* Modules
* Remote State
* Best Practices cho môi trường production
* Liên hệ Terraform với các kiến trúc AWS đã triển khai trong Phase 1 (Lambda, API Gateway, EventBridge, CloudWatch, IAM, S3)

---

# Day 2

## Kubernetes Foundation

### Cài đặt môi trường

Đã hoàn tất cài đặt và kiểm tra các công cụ cần thiết để chạy Kubernetes local:

```powershell
docker version
kubectl version --client
minikube version
```

Đã khởi động thành công cluster local bằng minikube:

```powershell
minikube start --driver=docker
kubectl get nodes
```

Kết quả:

```text
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   9h    v1.35.1
```

Điều này xác nhận Kubernetes cluster local đã hoạt động bình thường.

---

### Demo Kubernetes Application

Thực hiện deploy một ứng dụng nginx đơn giản bằng file `app.yaml`.

Các Kubernetes object đã được tạo:

```text
namespace/w8-demo
configmap/app-config
secret/app-secret
deployment.apps/nginx-app
service/nginx-service
networkpolicy.networking.k8s.io/allow-nginx-ingress
```

Kiểm tra các resource:

```powershell
kubectl get all -n w8-demo
kubectl get configmap -n w8-demo
kubectl get secret -n w8-demo
kubectl get networkpolicy -n w8-demo
```

Qua đó quan sát được cách Kubernetes tạo và quản lý:

* Namespace
* Pod
* Deployment
* ReplicaSet
* Service
* ConfigMap
* Secret
* NetworkPolicy

---

## Điều học được

### Pod

Pod là đơn vị deploy nhỏ nhất trong Kubernetes.

Pod mang tính ephemeral (có thể bị tạo lại bất kỳ lúc nào), vì vậy trong thực tế thường không quản lý Pod trực tiếp mà sử dụng Deployment.

---

### Deployment

Deployment mô tả trạng thái mong muốn (desired state) của ứng dụng.

Ví dụ:

```text
replicas = 2
image = nginx:alpine
```

Kubernetes sẽ cố gắng duy trì đúng số lượng Pod mong muốn.

Nếu Pod bị xóa hoặc gặp lỗi, Deployment sẽ tự tạo Pod mới để đưa hệ thống trở về trạng thái mong muốn.

---

### Service

Service cung cấp endpoint ổn định cho ứng dụng.

Do Pod có thể bị tạo lại và thay đổi IP, client không nên truy cập trực tiếp Pod mà nên truy cập thông qua Service.

Service đóng vai trò tương tự cơ chế service discovery hoặc internal load balancer trong hệ thống phân tán.

---

### ConfigMap

ConfigMap dùng để lưu các cấu hình không nhạy cảm.

Ví dụ:

```text
APP_NAME
APP_ENV
LOG_LEVEL
```

ConfigMap giúp tách cấu hình khỏi container image.

---

### Secret

Secret dùng để lưu các cấu hình nhạy cảm như:

```text
API_KEY
TOKEN
PASSWORD
```

Qua quá trình tìm hiểu nhận thấy Kubernetes Secret không phải là giải pháp quản lý bí mật hoàn chỉnh. Secret mặc định vẫn được lưu trong etcd và dữ liệu chỉ được encode dưới dạng Base64.

Trong môi trường production thường kết hợp với:

* KMS
* HashiCorp Vault
* AWS Secrets Manager

để tăng mức độ bảo mật.

---

### Probe

Probe là cơ chế Kubernetes sử dụng để đánh giá trạng thái của ứng dụng.

Ba loại probe chính:

#### Startup Probe

Kiểm tra ứng dụng đã khởi động hoàn tất hay chưa.

Phù hợp với các ứng dụng có thời gian startup dài.

#### Readiness Probe

Kiểm tra Pod đã sẵn sàng nhận traffic hay chưa.

Nếu readiness fail, Pod vẫn chạy nhưng Service sẽ không route request vào Pod đó.

#### Liveness Probe

Kiểm tra ứng dụng còn hoạt động bình thường hay không.

Nếu liveness fail, Kubernetes sẽ restart Pod.

---

### NetworkPolicy

NetworkPolicy là cơ chế kiểm soát giao tiếp mạng giữa các Pod.

Có thể xem như firewall ở tầng Kubernetes workload.

Khi kết hợp với:

* Namespace
* Labels
* NetworkPolicy

sẽ tạo nên cơ chế phân tách và kiểm soát truy cập tương đối giống với việc sử dụng VPC, Security Group và một phần NACL trong AWS.

---

## Liên hệ với Terraform

Một điểm thú vị là cả Terraform và Kubernetes đều hoạt động dựa trên khái niệm Desired State.

Terraform:

```text
Desired Infrastructure
↓
Terraform State
↓
Infrastructure thực tế
```

Kubernetes:

```text
Desired Workload
↓
Deployment
↓
Pods thực tế
```

Cả hai hệ thống đều liên tục so sánh trạng thái hiện tại với trạng thái mong muốn và thực hiện hành động để đưa hệ thống về đúng cấu hình đã khai báo.
