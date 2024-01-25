#The module used below automatically creates the s3 bucket and DynamoDB table and handles the state file migration on the following 'terraform init'

# Use the s3-state module for Terraform state storage
module "remote_state" {
  source = "ansraliant/s3-state/aws"

  bucket_name    = "deepansh-app-backend"
  dynamodb_table = "deepansh-app-backend-table"

  # This line specifies the configuration for remote state.
  #Deleting or keeping this line depends on your workflow and how you want to organize your Terraform configurations. If you only have a single environment or don't use workspaces, you might not need this line, and the default behavior will be sufficient. If you use multiple workspaces with different backend configurations, this line allows you to specify those configurations for each workspace.
  #infra is the folder name that will be created in the s3 bucket after hitting terraform init next time upon taking confirmation for migrating the state file. The latter part is where our current state file's local backup is being saved for reference with the remote backend.
  states = { infra = "../terraform/backend.tf.json" }
}


#Below is the configuration for backend.tf if we planned to go for the traditional option2 from https://github.com/orgs/gruntwork-io/discussions/769

# Configure the remote backend
#terraform {
#  backend "s3" {
#    bucket         = "your-unique-bucket-name"
#    dynamodb_table = "your-unique-lock-table-name"
#    key            = "terraform.tfstate"
#    region         = "us-east-1"
#    encrypt        = true
#  }
#}
