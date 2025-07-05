provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

# Create GCS bucket for raw data
resource "google_storage_bucket" "raw_data" {
  name     = "${var.project_id}-raw-data"
  location = var.region
  force_destroy = true
}

# Create GCS bucket for staging BigQuery loads
resource "google_storage_bucket" "bq_temp" {
  name     = "${var.project_id}-temp-bq"
  location = var.region
  force_destroy = true
}

# Create GCS bucket for storing spark scripts
resource "google_storage_bucket" "spark_jobs" {
  name     = "${var.project_id}-spark-jobs"
  location = var.region
  force_destroy = true
}

# Create a Dataproc cluster (minimal)
resource "google_dataproc_cluster" "dataproc_cluster" {
  name   = var.cluster_name
  region = var.region

  cluster_config {
    master_config {
      num_instances = 1
      machine_type  = "n1-standard-2"
      disk_config {
        boot_disk_size_gb = 30
      }
    }

    software_config {
      image_version       = "2.0-debian10"
      optional_components = ["JUPYTER"]
    }

    gce_cluster_config {
      service_account = var.service_account_email
    }
  }
}

variable "project_id" {}
variable "region" {
  default = "us-central1"
}
variable "cluster_name" {}
variable "credentials_file" {}
variable "service_account_email" {}
