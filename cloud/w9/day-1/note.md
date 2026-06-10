# D1 – GitOps & CI/CD

## Mục tiêu của buổi học

Buổi học này không thực sự nói về ArgoCD, Flux hay GitHub Actions.

Thứ được học là một triết lý:

> Git là nguồn sự thật duy nhất của hệ thống.

Mọi công cụ xuất hiện trong buổi học đều chỉ là hệ quả của nguyên lý này.

---

# 1. Vấn đề của cách deploy truyền thống

Giả sử có một hệ thống Kubernetes.

Developer deploy:

```bash
kubectl apply -f deployment.yaml
```

Một tuần sau:

```bash
kubectl scale deployment app --replicas=5
```

Một tháng sau:

```bash
kubectl edit deployment app
```

Ba tháng sau:

Không ai biết trạng thái thật của hệ thống nằm ở đâu.

Có thể:

* Trong Git
* Trong cluster
* Trong máy DevOps
* Trong tài liệu wiki

Mỗi nơi ghi một kiểu.

Hệ thống dần xuất hiện hiện tượng:

**Configuration Drift**

Tức là trạng thái thực tế của hệ thống dần lệch khỏi trạng thái được mô tả trong code.

---

## Ví dụ Drift

Git:

```yaml
replicas: 3
```

Cluster:

```yaml
replicas: 10
```

Tài liệu:

```text
replicas = 5
```

Không ai biết giá trị nào đúng.

---

# 2. GitOps ra đời để giải quyết điều gì?

GitOps đưa ra một luật chơi mới:

> Chỉ được thay đổi hệ thống bằng cách thay đổi Git.

Không sửa trực tiếp cluster.

Không click tay.

Không SSH vào server.

Không kubectl edit.

Mọi thay đổi phải đi qua Git.

---

## Git trở thành nguồn sự thật

Git lưu:

* Kubernetes manifests
* Helm charts
* Kustomize
* Terraform modules
* Cấu hình ứng dụng

Git không còn chỉ là nơi lưu code.

Git trở thành:

```text
Desired State
```

Trạng thái mong muốn của toàn bộ hệ thống.

---

## Desired State và Actual State

GitOps luôn tồn tại hai trạng thái:

### Desired State

Trạng thái mong muốn.

Ví dụ:

```yaml
replicas: 3
image: app:v2
```

### Actual State

Trạng thái đang chạy thật trong cluster.

Ví dụ:

```yaml
replicas: 5
image: app:v1
```

GitOps liên tục cố gắng biến:

```text
Actual State
```

thành

```text
Desired State
```

---

# 3. Reconciliation

Đây là từ khóa quan trọng nhất của GitOps.

Reconciliation nghĩa là:

> Liên tục so sánh trạng thái thực tế với trạng thái mong muốn rồi sửa lại nếu khác nhau.

Quá trình:

```text
Git
 ↓
Desired State

Kubernetes
 ↓
Actual State
```

Nếu khác:

```text
OutOfSync
```

thì tự sửa lại.

---

Ví dụ:

Git:

```yaml
replicas: 3
```

Cluster:

```yaml
replicas: 10
```

Hệ thống GitOps phát hiện:

```text
3 != 10
```

và tự scale về:

```yaml
replicas: 3
```

---

# 4. ArgoCD là gì?

ArgoCD là một GitOps Controller chạy trong Kubernetes.

Nhiệm vụ:

* Theo dõi Git
* Theo dõi Cluster
* So sánh hai bên
* Reconcile nếu lệch

---

## Hiểu ArgoCD bằng một vòng lặp

Có thể tưởng tượng:

```bash
while true
do
  compare Git vs Cluster

  if different:
     sync
done
```

ArgoCD thực hiện ý tưởng này nhưng:

* thông minh hơn
* an toàn hơn
* có rollback
* có health checking
* có dashboard

---

## Trạng thái thường thấy

### Synced

Git và Cluster giống nhau.

### OutOfSync

Git và Cluster khác nhau.

### Healthy

Ứng dụng đang chạy tốt.

### Degraded

Ứng dụng có lỗi.

---

# 5. Flux là gì?

Flux cũng là GitOps Controller.

Nguyên lý gần như giống ArgoCD.

---

## So sánh

### ArgoCD

Ưu điểm:

* Dashboard đẹp
* Dễ quan sát
* Dễ học

Thường được dùng trong:

* Demo
* Lab
* Team vừa và nhỏ

---

### Flux

Ưu điểm:

* Nhẹ
* Kubernetes-native hơn
* Ít phụ thuộc UI

Thường được dùng trong:

* Platform Engineering
* Internal Platform Teams

---

Điều cần nhớ:

```text
GitOps ≠ ArgoCD

GitOps = Triết lý

ArgoCD / Flux = Công cụ
```

---

# 6. GitHub Actions trong GitOps

GitHub Actions không phải GitOps tool.

Nó là CI/CD tool.

---

## CI là gì?

CI (Continuous Integration)

Mục tiêu:

* Build
* Test
* Validate

Ví dụ:

```text
Push Code
 ↓
Unit Test
 ↓
Build Docker Image
 ↓
Push Registry
```

---

## CD truyền thống

Ngày xưa:

```text
Git
 ↓
Jenkins
 ↓
kubectl apply
 ↓
Cluster
```

CI/CD tool deploy trực tiếp.

---

## CD kiểu GitOps

Git
↓

GitHub Actions
↓

Build Image
↓

Update Manifest
↓

Commit vào Git
↓

ArgoCD
↓

Cluster

---

Khác biệt lớn:

GitHub Actions không deploy trực tiếp.

Nó chỉ thay đổi Git.

ArgoCD mới là thứ deploy.

---

# 7. Plan-on-PR & Apply-on-Merge

Đây là cách đưa nguyên lý review vào hạ tầng.

---

## Khi mở Pull Request

Tự động chạy:

```bash
terraform fmt
terraform validate
terraform plan
```

hoặc:

```bash
helm lint
kubectl dry-run
```

Mục tiêu:

Xem trước điều gì sắp xảy ra.

---

Ví dụ:

```text
+ Create EC2
~ Update Security Group
- Delete RDS
```

Toàn team cùng review.

---

## Khi Merge

Mới thực sự:

```bash
terraform apply
```

hoặc:

Deploy phiên bản mới.

---

Ý nghĩa:

> Không ai được thay đổi production mà không review.

---

# 8. App-of-Apps

Khi hệ thống lớn:

```text
frontend
backend
monitoring
logging
database
```

Mỗi app là một Argo Application.

---

Nếu có 50 services:

```text
50 Argo Applications
```

rất khó quản lý.

---

Giải pháp:

```text
Root Application
 ├─ Frontend
 ├─ Backend
 ├─ Monitoring
 └─ Logging
```

Một Application quản lý các Application khác.

---

Mục tiêu:

* Dễ quản lý
* Dễ bootstrap cluster
* Dễ triển khai môi trường mới

---

# 9. Sync Waves

Một hệ thống không phải lúc nào cũng deploy cùng lúc được.

---

Ví dụ:

```text
Database
Backend
Frontend
```

Frontend cần Backend.

Backend cần Database.

---

Nếu deploy đồng thời:

Frontend có thể lên trước.

Kết quả:

```text
Connection Refused
```

---

Sync Waves cho phép:

Wave 0

```text
Database
```

Wave 1

```text
Backend
```

Wave 2

```text
Frontend
```

---

Tương tự:

```hcl
depends_on
```

trong Terraform.

---

# 10. Rollback trong GitOps

Rollback là quay lại trạng thái trước đó.

---

## Cách cũ

```bash
kubectl rollout undo
```

Kubernetes rollback về revision cũ.

---

Vấn đề

Git vẫn giữ:

```yaml
image: v2
```

Cluster:

```yaml
image: v1
```

ArgoCD nhìn thấy khác biệt.

---

Nó sẽ tự sửa:

```text
v1 → v2
```

Rollback biến mất.

---

## Cách đúng trong GitOps

```bash
git revert
```

Ví dụ:

```text
A
B
C
```

Commit C lỗi.

---

```bash
git revert C
```

Sinh commit mới:

```text
A
B
C
D(revert)
```

---

Git thay đổi.

ArgoCD sync.

Cluster quay lại trạng thái của B.

---

# Tổng kết

Toàn bộ buổi học có thể tóm gọn như sau:

1. Git trở thành nguồn sự thật của hệ thống.
2. ArgoCD/Flux liên tục reconcile Cluster với Git.
3. GitHub Actions chịu trách nhiệm CI và cập nhật Git.
4. App-of-Apps giúp quản lý nhiều ứng dụng.
5. Sync Waves giúp deploy đúng thứ tự phụ thuộc.
6. Rollback trong GitOps ưu tiên git revert thay vì kubectl rollout undo.
7. Mọi thay đổi hệ thống nên đi qua Pull Request → Review → Merge → Sync.
