provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "dark-army"
    key    = "development"
    region = "us-east-2"
  }
}
