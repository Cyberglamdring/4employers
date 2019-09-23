provider "aws" {
  // region                  = "us-east-1"
  region                  = "${var.region}"
  shared_credentials_file = "/home/student/.aws/credentials"
  profile                 = "default"
}
