variable "region" {
  type        = string
  description = "Region of the S3 bucket"
  default     = "eu-west-1"
}

variable "application" {
  type        = string
  description = "Application that uses the S3 bucket"
  default     = "ctx"
}
