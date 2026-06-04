terraform {
  required_version = ">= 1.0"
}

locals {
  name = "hello-terraform"
}

output "message" {
  value = local.name
}
