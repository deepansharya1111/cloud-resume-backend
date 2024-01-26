# Cloud-Resume-Backend

This Terraform setup uses the `ansraliant/s3-state/aws` module to configure a remote backend with S3 and DynamoDB for storing Terraform state.

#### Click here for 👉 [Cloud Resume Frontend](https://github.com/deepansharya1111/cloud-resume-frontend/tree/main).

## Prerequisites for creating the cloud infrastructure with given code

- [Terraform](https://www.terraform.io/) installed on your machine.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured for AWS credentials with sufficient permissions
  - After installing AWS CLI
  - RUN "aws configure"
  - Get Credentials: "right-click-on-AWS-profile -> security-credentials -> Create-Access-Keys.
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) for creating a Google Cloud storage bucket. Ensure you have an account with a project with billing enabled.
  - "gcloud init" -> "gcloud projects list" -> "gcloud config set project your_project_id"
  - Terraform requires gcloud's `credentials` or `access_token` refer [1](https://cloud.google.com/iam/docs/keys-list-get) & [2](https://youtu.be/0PwvhWa3OOY?si=iT1QEhvD22xfqvPI). Set manually or run `gcloud auth application-default login`.

#### Or Import your own infrastructure created from the console to recreate similar code structure:

* Define the basic terraform code for your resources.
  * Run "terraform init"
  * ''terraform validate"
  * ''terraform import resource.resource_name resource_identifier"
  * "terraform scan"
    * Find and copy the imported code block for your resource.
    * Replace the code with the basic code in your Terraform files.
  * "terraform validate" to know which code lines we need to remove from our Terraform files.
  * Refine the code by replacing deprecated code blocks to resolve the warnings mentioned upon running "terraform plan" with the respective updated resource blocks.
  * "terraform apply" will show that it is creating new resources. This is normal since Terraform considers separate resource blocks to be different resources. However, it shall not affect your existing infrastructure as long as you have used the original code or resolved the "terraform plan" warnings carefully.

## Usage

1. Clone this repository:

   ```bash
   git clone git@github.com:deepansharya1111/cloud-resume-backend.git
   cd cloud-resume-backend/terraform/
   ```
   
2. Customisation: replace the highlighted texts with your desired globally unique names. Run `terraform fmt` to format if additional changes are made.

   - For Terraform Remote Backend with S3 and DynamoDB, change the `bucket_name` and `dynamodb_table` names in `backend.tf`.
   - For creating a GCP Storage bucket, change the `project` and `name` variables in `gcp.tf`.
   - AWS Resources:
     - For the S3 bucket to store the frontend code, change every `deepansh_app_bucket` and `deepansh.app` in `aws.tf`.
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
   
7. See Google Cloud storage buckets:
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
`aws.tf`: Contains the main AWS Terraform configuration.

`backend.tf`: Includes the ansraliant/s3-state/aws module for remote state configuration.

`provider.tf`: Contains the AWS provider configuration.

`gcp.tf`: Contains the GCP provider and Cloud Storage Bucket configurations for hosting static websites.

``backend.tf.json`: Backend configuration file with details for S3 bucket, key, region, and DynamoDB table.
