# W9 D2 – Observability Research Notes

## Tổng quan

Observability là khả năng quan sát và đánh giá trạng thái của một hệ thống thông qua dữ liệu vận hành.

Ba trụ cột chính:

* Metrics
* Logs
* Traces

Mục tiêu là không chỉ biết hệ thống đang gặp vấn đề mà còn hiểu nguyên nhân gây ra vấn đề đó.

---

## Prometheus

Prometheus là hệ thống thu thập và lưu trữ metrics dưới dạng time-series.

Prometheus định kỳ gọi endpoint:

```text
/metrics
```

của ứng dụng để thu thập dữ liệu.

Ví dụ metrics trong demo:

```text
http_requests_total
http_request_duration_seconds
```

Prometheus giúp trả lời:

* Có bao nhiêu request?
* Error rate hiện tại là bao nhiêu?
* Latency có đang tăng không?

---

## Grafana

Grafana là công cụ trực quan hóa dữ liệu.

Grafana không tự thu thập metrics.

Thay vào đó nó truy vấn dữ liệu từ:

* Prometheus
* Loki
* Tempo
* Elasticsearch
* nhiều nguồn khác

Grafana giúp hiển thị:

* Dashboard
* Graph
* Alert
* Panel theo thời gian

---

## Loki

Loki là hệ thống lưu trữ và truy vấn log.

Prometheus chỉ cho biết:

```text
Error rate tăng
```

Nhưng không cho biết:

```text
Lỗi gì xảy ra?
```

Loki lưu log để có thể tra cứu:

```text
INFO User login success
WARN Retry database connection
ERROR Database timeout
```

Grafana có thể truy vấn Loki để xem log chi tiết.

---

## SLI (Service Level Indicator)

SLI là chỉ số đo lường chất lượng dịch vụ.

Ví dụ:

* Availability
* Error Rate
* Request Latency

SLI là giá trị thực tế đo được từ hệ thống.

Ví dụ:

```text
Availability = 99.7%
```

---

## SLO (Service Level Objective)

SLO là mục tiêu mong muốn đối với một SLI.

Ví dụ:

```text
Availability >= 99%
```

hoặc

```text
95% requests < 500ms
```

SLO giúp xác định mức độ tin cậy mong muốn của hệ thống.

---

## Error Budget

Error Budget là phần lỗi được phép tồn tại theo SLO.

Ví dụ:

```text
SLO = 99%
```

Cho phép:

```text
1% lỗi
```

Đó chính là Error Budget.

---

## Burn Rate

Burn Rate là tốc độ tiêu hao Error Budget.

Ví dụ:

```text
Error Budget = 1%
```

Nếu hệ thống đang tạo:

```text
10% request lỗi
```

thì Error Budget đang bị tiêu hao rất nhanh.

Burn Rate càng cao thì nguy cơ vi phạm SLO càng lớn.

---

## OpenTelemetry (OTel)

OpenTelemetry là tiêu chuẩn mở cho việc thu thập telemetry.

Telemetry bao gồm:

* Metrics
* Logs
* Traces

---

## OTel SDK

OTel SDK được tích hợp vào ứng dụng.

Chức năng:

* Thu thập metrics
* Thu thập logs
* Sinh traces

Ví dụ với FastAPI:

```python
FastAPIInstrumentor.instrument_app(app)
```

SDK tự động ghi nhận:

* Request count
* Response time
* HTTP status code
* Trace information

---

## OTel Collector

OTel Collector là thành phần trung gian nhận telemetry từ các ứng dụng.

Collector thực hiện:

* Receive
* Process
* Export

Kiến trúc:

Application
→ OTel SDK
→ OTel Collector
→ Prometheus / Loki / Jaeger

Collector giúp tách ứng dụng khỏi các backend monitoring cụ thể và trở thành điểm tập trung xử lý telemetry.