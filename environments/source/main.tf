
module "test_source_bucket" {
  source = "../../modules/create_source_bucket"

  source_bucket_name             = "test-replication-source"
  source_replication_policy_name = "test-replication-policy"
  source_replication_role_name   = "test-replication-role"
  destination_account_id         = "1234567890"
  destination_bucket_arn         = "arn:aws:s3:::test-replication-target"
  logging_bucket_name            = "s3-logs"
}
