# W8 Reflection

## Day 1

### Infrastructure as Code (IaC)

IaC là cách mô tả hạ tầng bằng code thay vì thao tác thủ công trên giao diện.

Triết lý của IaC là toàn bộ hạ tầng có thể được định nghĩa, quản lý và tái tạo bằng mã nguồn. Điều này giúp các môi trường Dev, Test, Staging và Production có tính nhất quán cao, giảm lỗi do cấu hình thủ công và dễ dàng version control bằng Git.

### Một số công cụ liên quan

- Terraform
- OpenTofu
- AWS CloudFormation
- Pulumi
- Ansible (thiên về configuration management)

### Thực hành hôm nay

Đã cài đặt Terraform trên Windows bằng Chocolatey.

Đã chạy thành công:

- terraform init
- terraform plan

Thử nghiệm với cấu hình đơn giản sử dụng:
- locals
- output

Kết quả:

message = "hello-terraform"

### Điều học được

Terraform hoạt động theo mô hình:

Configuration (.tf)
→ Plan
→ Apply
→ State

Terraform không trực tiếp quản lý hạ tầng từ code mà sử dụng provider để giao tiếp với nền tảng đích (AWS, Azure, GCP...).
