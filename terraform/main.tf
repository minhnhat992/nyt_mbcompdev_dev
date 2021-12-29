terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.0.0"
    }
  }
}

provider "google" {
  credentials = file(var.terraform_credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

terraform {
  backend "gcs" {
    credentials = file(var.gcs_credentials_file)
    bucket = "tf-composer-state-mb"
    prefix = "cloud-composer-1"

  }
}

resource "google_composer_environment" "cc_env_mb" {
  name    = "my-own-cc"
  project = var.project
  region  = var.region
  config {
    node_count = 4
    node_config {
      zone            = var.zone
      network         = google_compute_network.cc_env_mb.id
      subnetwork      = google_compute_subnetwork.cc_env_mb.id
      service_account = google_service_account.cc_env_mb.name
      machine_type    = "n1-standard-4"
    }

    software_config {
      image_version            = "composer-1.17.7-airflow-1.10.15"
      airflow_config_overrides = {
        core-dags_are_paused_at_creation = "True"
      }

      #      pypi_packages = {
      #        numpy = ""
      #        scipy = "==1.1.0"
      #      }

      env_variables  = {
        FOO = "bar"
      }
      python_version = "3"

    }


#    private_environment_config {
#      enable_private_endpoint = true
#    }
  }
}


resource "google_compute_network" "cc_env_mb" {
  name                    = "composer-test-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "cc_env_mb" {
  name          = "composer-test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.cc_env_mb.id
}

resource "google_service_account" "cc_env_mb" {
  account_id   = "composer-env-account"
  display_name = "Test Service Account for Composer Environment"
}

resource "google_project_iam_member" "cc_env_mb" {
  project = var.project
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.cc_env_mb.email}"
}