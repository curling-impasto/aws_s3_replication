provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Application = var.application
    }
  }
}

terraform {

  backend "s3" {
    bucket                 = "operations-tfstate"
    key                    = "s3-replication-terraform.tfstate"
    region                 = "eu-west-1"
    skip_region_validation = true
  }
}
