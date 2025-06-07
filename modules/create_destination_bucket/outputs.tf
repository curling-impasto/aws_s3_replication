output "bucket_arn" {
  value       = aws_s3_bucket.cdr_bucket.arn
  description = "ARN of the newly created bucket"
}

output "bucket_id" {
  value       = aws_s3_bucket.cdr_bucket.id
  description = "ARN of the newly created bucket"
}
