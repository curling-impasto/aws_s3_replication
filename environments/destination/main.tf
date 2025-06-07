
# Source Bucket to act as Destination for Custoemer
module "target_bucket" {
  source = "../../../../modules/create_destination_bucket"

  bucket_name      = "store-destination"
  customer         = "sample"
  replication_role = "arn:aws:iam::123456789:role/service-role/role_for_source"
  glacier_class    = "GLACIER_IR"
}
