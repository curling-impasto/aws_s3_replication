variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "replication_role" {
  type        = string
  description = "ARN of the IAM role for replication"
}

variable "customer" {
  type        = string
  description = "Application that uses the S3 bucket"
  default     = "internal"
}

variable "glacier_class" {
  type        = string
  description = "Days after to move to glacier"
  default     = "GLACIER"
}
