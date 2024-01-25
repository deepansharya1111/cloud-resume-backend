# Cloud-Resume-Backend
## Terraform Remote Backend with S3 and DynamoDB

This Terraform setup uses the `ansraliant/s3-state/aws` module to configure a remote backend with S3 and DynamoDB for storing Terraform state.

## Prerequisites

- [Terraform](https://www.terraform.io/) installed on your machine.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured for AWS credentials with sufficient permissions
  - After installing AWS CLI
  - RUN "aws configure"
  - Get Credentials: "right-click-on-AWS-profile -> security-credentials -> Create-Access-Keys.
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) for creating a Google Cloud storage bucket. Ensure you have an account with a project with billing enabled.
  - "gcloud init" -> "gcloud projects list" -> "gcloud config set project your_project_id"
  - Terraform requires gcloud's `credentials` or `access_token`. Set manually or run `gcloud auth application-default login`.

## Usage

1. Clone this repository:

   ```bash
   git clone git@github.com:deepansharya1111/cloud-resume-backend.git
   cd cloud-resume-backend/terraform/
   ```
2. (Optional) Customise the `bucket_name` and `dynamodb_table` names in backend.tf or `project` and `name` variables in gcp.tf with your desired globally unique names. Run `terraform fmt` to format if additional changes are made.
3. Initialize Terraform:
   ```
   terraform init
   ```
4. Validate your Terraform configuration:
   ```
   terraform validate
   ```
5. Plan your Terraform configuration:
   ```
   terraform plan
   ```
6. Apply your Terraform configuration:
   ```
   terraform apply
   ```
7. See Google cloud storage buckets:
   ```
   gsutil ls
   ```
8. See AWS DynamoDB tables
   ```
   aws dynamodb list-tables
   ```
9. See AWS S3 bucket
   ```
   aws s3 ls
   ```

## Configuration Details
`main.tf`: Contains the main Terraform configuration, including the use of the ansraliant/s3-state/aws module and backend configuration.
`backend.tf.json`: Backend configuration file with details for S3 bucket, key, region, and DynamoDB table.
