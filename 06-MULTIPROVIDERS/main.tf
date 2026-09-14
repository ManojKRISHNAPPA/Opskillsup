resource "random_string" "bucket_prefix_tokyo" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}


resource "random_string" "bucket_prefix_mumbai" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "aws_s3_bucket" "tokyo" {
  bucket   = "${var.bucket_name}-${random_string.bucket_prefix_tokyo.result}"
  provider = aws.tokyo
}


resource "aws_s3_bucket" "mumbai" {
  bucket   = "${var.bucket_name}-${random_string.bucket_prefix_mumbai.result}"
  provider = aws.mumbai
}