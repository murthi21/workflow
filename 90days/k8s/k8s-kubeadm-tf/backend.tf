terraform {
  backend "s3" {
    bucket         = "murthi-terraform-backend"   # change bucket name (must be globally unique)
    key            = "k8s/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
  }
}

