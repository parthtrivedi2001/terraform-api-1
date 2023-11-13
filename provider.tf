terraform {
  #  backend "s3" {
  #    bucket = "terraform-state-file-bucket-manage"
  #    # dynamodb_table = "state-lock"
  #    key    = "global/mystatefile/terraform.tfstate"
  #    region = "ap-south-1"
  #    encrypt = true
  #  } 
}
  
provider "aws" {
  region = "ap-south-1"
}

# provider "aws" {
#   profile = "mainaccount"
#   alias = "mainaccount"
#   region = "ap-south-1"
# }