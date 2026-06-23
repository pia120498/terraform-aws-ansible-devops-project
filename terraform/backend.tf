terraform {
  backend "s3" {
    bucket       = "priyaa-terraform-state-bucket"
    key          = "terraform-ansible-project/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}