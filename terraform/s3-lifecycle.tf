resource "aws_s3_bucket_lifecycle_configuration" "state_lifecycle" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "archive-old-state-versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}