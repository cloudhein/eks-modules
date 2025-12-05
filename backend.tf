terraform {
  backend "s3" {
    bucket       = "remote-state-bucket-dev-007"
    key          = "terraform/dev/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
    profile      = "admin-cli"
  }
}