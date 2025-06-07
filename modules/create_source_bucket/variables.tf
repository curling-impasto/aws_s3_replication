variable "source_bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "logging_bucket_name" {
  type        = string
  description = "Name of the S3 Server acess logs bucket"
}

variable "destination_bucket_arn" {
  type        = string
  description = "ARN of the destination S3 bucket"
}

variable "destination_account_id" {
  type        = string
  description = "ARN of the destination S3 bucket"
}

variable "source_replication_role_name" {
  type        = string
  description = "Name of Source replication Role"
}

variable "source_replication_policy_name" {
  type        = string
  description = "Name of Source replication Policy"
}
