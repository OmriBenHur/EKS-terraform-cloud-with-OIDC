# s3 bucket to house terraform state file, to allow remote interaction with terraform from multiple sources
# replace the bucket,kms key id and region to the valid values that suit your environment
terraform {
  cloud {
    organization = "omribenhur"

    workspaces {
      name = "eks-application"
    }
  }
}

# provider conf. enter the region you're operating in
provider "aws" {
  region = "us-west-2"
}
