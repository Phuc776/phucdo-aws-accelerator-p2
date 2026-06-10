# D3 — Progressive Delivery Research

## Mục tiêu

Hiểu cách triển khai phiên bản mới của ứng dụng một cách an toàn thay vì cập nhật đồng loạt cho toàn bộ người dùng.

Progressive Delivery là tập hợp các kỹ thuật triển khai cho phép phát hành phần mềm theo từng bước nhỏ, đo lường kết quả thực tế và tự động dừng hoặc rollback nếu phát hiện vấn đề.

---

# Từ Deployment truyền thống đến Progressive Delivery

## Traditional Deployment

Triển khai cho toàn bộ người dùng cùng lúc.

```text
v1
↓
Deploy
↓
100% người dùng dùng v2
```

Ưu điểm:

- Nhanh
- Đơn giản

Nhược điểm:

- Nếu lỗi xảy ra sẽ ảnh hưởng toàn bộ hệ thống
- Rollback thường mang tính phản ứng sau khi sự cố đã xuất hiện

---

## Progressive Delivery

Triển khai dần dần.

```text
v1
↓
5%
↓
20%
↓
50%
↓
100%
```

Sau mỗi bước:

- Theo dõi metrics
- Theo dõi logs
- Theo dõi traces
- Đánh giá SLO

Nếu phát hiện bất thường:

```text
Abort
↓
Rollback
```

---

# Canary Release

Canary là kỹ thuật phổ biến nhất trong Progressive Delivery.

Tên gọi xuất phát từ việc thợ mỏ từng mang chim hoàng yến xuống hầm để phát hiện khí độc trước con người.

Ý tưởng:

- Một nhóm nhỏ người dùng sử dụng phiên bản mới
- Phần còn lại vẫn dùng phiên bản cũ

Ví dụ:

```text
90% traffic → v1
10% traffic → v2
```

Nếu ổn:

```text
50% → v2
```

Sau đó:

```text
100% → v2
```

---

# Argo Rollouts

Argo Rollouts là một Kubernetes Controller mở rộng Deployment truyền thống.

Thay vì:

```yaml
kind: Deployment
```

có thể sử dụng:

```yaml
kind: Rollout
```

Argo Rollouts hỗ trợ:

- Canary
- Blue/Green Deployment
- Automated Rollback
- Progressive Delivery

---

# Rollout CRD

CRD (Custom Resource Definition) là cơ chế mở rộng Kubernetes API.

Argo Rollouts bổ sung resource mới:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
```

Kubernetes lúc này hiểu thêm một loại workload mới ngoài Deployment.

---

# Canary Steps

Ví dụ:

```yaml
strategy:
  canary:
    steps:
      - setWeight: 20
      - pause: {}
      - setWeight: 50
      - pause: {}
      - setWeight: 100
```

Ý nghĩa:

```text
20% traffic
↓
Pause
↓
50% traffic
↓
Pause
↓
100% traffic
```

Tại mỗi lần pause:

- Kiểm tra metrics
- Kiểm tra logs
- Kiểm tra SLO

---

# AnalysisTemplate

AnalysisTemplate định nghĩa các tiêu chí đánh giá rollout.

Ví dụ:

```yaml
kind: AnalysisTemplate
```

Nó có thể đọc dữ liệu từ:

- Prometheus
- Datadog
- New Relic
- Web API

---

## Ví dụ Prometheus Query

Tính tỷ lệ lỗi:

```promql
rate(http_requests_total{status=~"5.."}[5m])
```

Hoặc:

```promql
histogram_quantile(...)
```

để kiểm tra latency.

---

# Automated Analysis

Flow:

```text
Canary Step
↓
AnalysisTemplate
↓
Prometheus Query
↓
Pass / Fail
```

Nếu pass:

```text
Tiếp tục rollout
```

Nếu fail:

```text
Abort
```

---

# Abort Criteria

Điều kiện dừng rollout.

Ví dụ:

```text
Error rate > 5%
```

Hoặc:

```text
P95 latency > 500ms
```

Hoặc:

```text
Availability < 99%
```

Khi vượt ngưỡng:

```text
Abort
↓
Rollback
```

---

# Rollback

Rollback là đưa hệ thống trở về phiên bản trước đó.

Ví dụ:

```text
v1
↓
Deploy v2
↓
Lỗi
↓
Rollback
↓
v1
```

Mục tiêu:

- Giảm thời gian downtime
- Giảm blast radius

---

# Liên hệ với Observability

Progressive Delivery phụ thuộc rất nhiều vào Observability.

Nếu không đo lường được hệ thống thì không thể quyết định:

```text
Tiếp tục rollout
hay
Rollback
```

Ba nguồn dữ liệu chính:

- Metrics
- Logs
- Traces

---

# Burn Rate

Burn Rate đo tốc độ tiêu hao Error Budget.

Ví dụ:

```text
SLO = 99.9%
```

Cho phép:

```text
0.1% lỗi
```

Nếu rollout mới làm lỗi tăng mạnh:

```text
Burn Rate tăng
```

đó là dấu hiệu hệ thống đang tiêu hao Error Budget quá nhanh.

---

# Burn Rate và Canary

Flow:

```text
Prometheus
↓
Burn Rate
↓
AnalysisTemplate
↓
Argo Rollouts
↓
Abort
```

Nhờ đó rollout có thể tự động dừng trước khi ảnh hưởng toàn bộ người dùng.

---

# Mental Model

GitOps trả lời:

"Deploy cái gì?"

ArgoCD trả lời:

"Làm sao đồng bộ trạng thái mong muốn?"

Progressive Delivery trả lời:

"Làm sao phát hành phiên bản mới một cách an toàn?"

Observability trả lời:

"Lấy dữ liệu gì để quyết định rollout có thành công hay không?"