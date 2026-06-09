resource "aws_ecr_repository" "app" {
  name         = var.app_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.app_name
  }
}

resource "null_resource" "docker_build_push" {
  depends_on = [aws_ecr_repository.app]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../python-app"
    interpreter = ["PowerShell", "-Command"]

    command = <<EOT
$ErrorActionPreference = "Stop"

aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

docker build -t ${var.app_name}:latest .

docker tag ${var.app_name}:latest ${aws_ecr_repository.app.repository_url}:latest

docker push ${aws_ecr_repository.app.repository_url}:latest
EOT
  }
}
