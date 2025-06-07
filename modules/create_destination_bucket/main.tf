# Create an S3 bucket with AWS managed keys
resource "aws_s3_bucket" "cdr_bucket" {
  bucket = var.bucket_name
  tags = merge(
    { Customer = var.customer }
  )
}

# enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.cdr_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# enable versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.cdr_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "transition_to_glacier" {
  bucket = aws_s3_bucket.cdr_bucket.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    filter {
      prefix = "" # Applies to all objects
    }

    transition {
      days          = 180
      storage_class = var.glacier_class
    }
  }
}


# Create a bucket policy to allow replication from a different source account
resource "aws_s3_bucket_policy" "replication_policy" {
  bucket = aws_s3_bucket.cdr_bucket.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "PolicyForDestinationBucket",
    "Statement" : [
      {
        "Sid" : "ReplicationPermissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${var.replication_role}"
        },
        "Action" : [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:ObjectOwnerOverrideToBucketOwner",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource" : "${aws_s3_bucket.cdr_bucket.arn}/*"
      },
      {
        "Sid" : "AllowSSLRequestsOnly",
        "Effect" : "Deny",
        "Principal" : "*",
        "Action" : "s3:*",
        "Resource" : [
          "${aws_s3_bucket.cdr_bucket.arn}",
          "${aws_s3_bucket.cdr_bucket.arn}/*"
        ],
        "Condition" : {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })
}
