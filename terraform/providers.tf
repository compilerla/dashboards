terraform {
  required_version = ">= 1.16.0"

  backend "gcs" {
    bucket = "data-warehouse-492522-tfstate"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
