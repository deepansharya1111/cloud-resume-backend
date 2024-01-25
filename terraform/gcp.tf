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


#THERE ARE DIFFERENT WAYS OF MANAGING ACCESS CONTROL IN GOOGLE CLOUD STORAGE. Like "google_storage_bucket_iam_binding" or "google_iam_policy" or "google_storage_default_object_access_control" or "google_storage_bucket_access_control"

#Here, I am using the first one as IAM policy can only be used when uniform_bucket_level_access is set to true.

#This section uses IAM policies to control access. It's a more granular way to manage access controls and allows you to define different roles for different members or groups. In this case, it's granting roles/storage.objectViewer to allUsers.
#https://stackoverflow.com/a/60092530/15044789

resource "google_storage_bucket_iam_binding" "public_access" {
  bucket = google_storage_bucket.gcp-static-site-bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    # List of users/groups that should have access
    # "user:your-email@example.com",
    "allUsers",
  ]
}