terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      service = "recessionindicator"
    }
  }
}

data "aws_route53_zone" "main" {
  name         = var.dot_com_domain_name
  private_zone = false
}

resource "aws_s3_bucket" "main" {
  bucket = "recessionindicator.com"
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = ["${aws_s3_bucket.main.arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.main.bucket
  key          = "index.html"
  source       = "./index.html"
  content_type = "text/html"

  etag = filemd5("./index.html")
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.main.bucket
  key          = "style.css"
  source       = "./style.css"
  content_type = "text/css"

  etag = filemd5("./style.css")
}

resource "aws_s3_object" "about" {
  bucket       = aws_s3_bucket.main.bucket
  key          = "about.html"
  source       = "./about.html"
  content_type = "text/html"

  etag = filemd5("./about.html")
}

resource "aws_s3_object" "favicon" {
  bucket       = aws_s3_bucket.main.bucket
  key          = "favicon.svg"
  source       = "./favicon.svg"
  content_type = "image/svg+xml"

  etag = filemd5("./favicon.svg")
}
