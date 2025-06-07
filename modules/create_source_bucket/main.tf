# Create an S3 bucket with AWS managed keys
resource "aws_s3_bucket" "source_bucket" {
  bucket = var.source_bucket_name
}

# enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.source_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# enable versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.source_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Define the IAM role for replication
data "aws_iam_policy_document" "replication_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetReplicationConfiguration",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.source_bucket.arn}/*"
//      "${data.aws_s3_bucket.logging_bucket.arn}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:GetObjectVersionTagging"
    ]

    resources = [
      "${var.destination_bucket_arn}/*"
    ]
  }
}

# Define the data source for the assume role policy
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com", "batchoperations.s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "replication_role" {
  name               = var.source_replication_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "replication_policy" {
  name   = var.source_replication_role_name
  policy = data.aws_iam_policy_document.replication_role_policy.json
}

resource "aws_iam_role_policy_attachment" "replication_role_policy_attachment" {
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

# Define the replication configuration
resource "aws_s3_bucket_replication_configuration" "replication_configuration" {
  role   = aws_iam_role.replication_role.arn
  bucket = aws_s3_bucket.source_bucket.id

  rule {
    id     = "replicate-to-target-account"
    status = "Enabled"

    destination {
      bucket        = var.destination_bucket_arn
      storage_class = "STANDARD"
      account       = var.destination_account_id
    }
  }
}

# Define the logging for S3 bucket
# data "aws_s3_bucket" "logging_bucket" {
#   bucket = var.logging_bucket_name
# }

# resource "aws_s3_bucket_policy" "logging_policy" {
#   bucket = var.logging_bucket_name

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Id" : "PolicyForLoggingBucket",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "s3.amazonaws.com"
#         },
#         "Action" : "s3:PutObject",
#         "Resource" : [
#           "${data.aws_s3_bucket.logging_bucket.arn}/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_s3_bucket_logging" "logging_configuration" {
#   bucket        = aws_s3_bucket.source_bucket.id
#   target_bucket = var.logging_bucket_name
#   target_prefix = "${var.source_bucket_name}/"
# }