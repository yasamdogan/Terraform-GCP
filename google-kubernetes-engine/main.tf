terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("credentials.json")
  project = var.project
}


resource "google_container_cluster" "primary" {
  name     = "gke-terraform-example"
  location = "europe-central2"
  remove_default_node_pool = true
  initial_node_count       = 1
  default_max_pods_per_node = 20
  network_policy {
      provider = "CALICO"
      enabled = true

  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "gke-terraform-example-node-pool"
  location   = "europe-central2"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_type = "pd-standard"
    disk_size_gb = 10
    service_account = var.google_service_account
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  
  autoscaling {
      min_node_count = 1
      max_node_count = 3
  }  
  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }
   
}