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
