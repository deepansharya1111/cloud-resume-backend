# Use the s3-state module for Terraform state storage
module "remote_state" {
  source = "ansraliant/s3-state/aws"

  bucket_name    = "deepansh-app-backend"
  dynamodb_table = "deepansh-app-backend-table"

  # This line specifies the configuration for remote state
  #Deleting or keeping this line depends on your workflow and how you want to organize your Terraform configurations. If you only have a single environment or don't use workspaces, you might not need this line, and the default behavior will be sufficient. If you use multiple workspaces with different backend configurations, this line allows you to specify those configurations for each workspace.
  states         = { infra = "../terraform/backend.tf.json" }
}

# Configure the remote backend
#terraform {
#  backend "s3" {
#    bucket         = "deepansh-app-backend"
#    dynamodb_table = "deepansh-app-backend-table"
#    key            = "terraform/terraform.tfstate"
#    region         = "us-east-1"
#    encrypt        = true
#  }
#}
