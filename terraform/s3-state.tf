resource "aws_s3_bucket" "terraform_state" {
  bucket = "priyaa-terraform-state-bucket"

  # lifecycle {
  #   prevent_destroy = true
  # }
}