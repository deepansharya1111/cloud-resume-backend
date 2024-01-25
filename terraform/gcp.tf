#Provider declaration for GCS bucket
provider "google" {
  project = "deepansh-app"
}

# Bucket configured for static website: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "gcp-static-site-bucket" {
  name          = "www.deepansh.app"
  location      = "US"
  storage_class = "STANDARD"
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
    origin          = ["http://deepansh.app"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}


#THERE ARE DIFFERENT WAYS OF MANAGING ACCESS CONTROL IN GOOGLE CLOUD STORAGE. For a static website, you usually want to make the content publicly accessible, so either the first or the second approach would be sufficient. 
#But Here, I am using the first one as only IAM policy can be used when uniform_bucket_level_access is set to true.

#1) google_storage_bucket_iam_policy Resource: This section is using IAM policies to control access. It's a more granular way to manage access controls, and it allows you to define different roles for different members or groups. In this case, it's granting roles/storage.objectViewer to allUsers.
#https://stackoverflow.com/a/60092530/15044789

data "google_iam_policy" "viewer" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
      # List of users/groups that should have access
      # "user:your-email@example.com",
      "allUsers",
    ]
  }
}

#2) google_storage_bucket_access_control Resource: This section explicitly grants read access (READER role) to all users (allUsers). This is a simple way to make your bucket public. But USING it with UBLA set to true will give an error = error googleapi: Error 400: Cannot use ACL API to update bucket policy when uniform bucket-level access is enabled. Read more at https://cloud.google.com/storage/docs/uniform-bucket-level-access.
#resource "google_storage_bucket_access_control" "public_rule" {
#  bucket = google_storage_bucket.gcp-static-site-bucket.name
#  role   = "READER"
#  entity = "allUsers"
#}

#3) google_storage_default_object_access_control Resource: This section sets default object ACLs, meaning that any new object uploaded to the bucket will inherit these access controls by default. It achieves the same goal of making your bucket publicly readable.
#resource "google_storage_default_object_access_control" "public_rule" {
#  bucket = google_storage_bucket.bucket.name
#  role   = "READER"
#  entity = "allUsers"
#}
