resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "insecure-demo-bucket"
}

resource "aws_s3_bucket_public_access_block" "insecure_bucket" {
  bucket = aws_s3_bucket.insecure_bucket.id

  block_public_acls       = true # SNYK-CC-TF-95
  block_public_policy     = true #SNYK-CC-TF-96
  ignore_public_acls      = true # SNYK-CC-TF-95
  restrict_public_buckets = true #SNYK-CC-TF-98 04.06
}

resource "aws_security_group" "wide_open" {
  name = "wide-open-sg"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["192.16.0.0/24"] #snyk-cc-tf-1 04/06/2026 
  }
}

resource "aws_iam_policy" "wildcard_policy" {
  name = "wildcard-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:ListBucket" # SNYK-CC-TF-69 04/06 "*"Allows every single AWS action
      Resource = "arn:aws:s3:::insecure-demo-bucket"             # "*"Applies to every AWS resource
    }]
  })
}

resource "aws_instance" "no_imdsv2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true    # ← add this
  }
}

# resource "aws_instance" "no_imdsv2" {
#   ami           = "ami-0c55b159cbfafe1f0"
#   instance_type = "t2.micro"

#   metadata_options {
#     http_tokens = "optional"
#   }
# }


