# Cloud-Resume-Backend
## Terraform Remote Backend with S3 and DynamoDB

This Terraform setup uses the `ansraliant/s3-state/aws` module to configure a remote backend with S3 and DynamoDB for storing Terraform state.

## Prerequisites

- [Terraform](https://www.terraform.io/) installed on your machine.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured for AWS credentials with sufficient permissions
  - After installing AWS CLI
  - RUN "aws configure"
  - Get Credentials: "right-click-on-AWS-profile -> security-credentials -> Create-Access-Keys.

## Usage

1. Clone this repository:

   ```bash
   git clone git@github.com:deepansharya1111/cloud-resume-backend.git
   cd cloud-resume-backend
   ```
2. (Optional) Customise the bucket_name and dynamodb_table names in backend.tf and main.tf with your desired globally unique names. Run `terraform fmt` to format if additional changes are made.
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

## Configuration Details
`main.tf`: Contains the main Terraform configuration, including the use of the ansraliant/s3-state/aws module and backend configuration.
`backend.tf.json`: Backend configuration file with details for S3 bucket, key, region, and DynamoDB table.
