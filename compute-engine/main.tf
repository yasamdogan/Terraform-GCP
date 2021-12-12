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
  region  = "europe-west3"
  zone    = "europe-west3-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-gcp-network"
}

resource "google_compute_firewall" "terraform-network" {
  name     = "terraform-gcp-firewall"
  network  = "terraform-gcp-network"
  priority = 10000
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0" , "192.168.2.0/24"]
  target_service_accounts = [var.service_account]
 
  allow {
    protocol = "tcp"
    ports    = ["20", "22", "80", "8080", "9090"]
  }


}

resource "google_compute_network" "terraform-gcp-network" {
  name = "terraform-gcp-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-gcp-server"
  machine_type = "e2-medium"
  tags = ["http"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
    
  }
  service_account {
  email = var.service_account
  scopes = ["cloud-platform"]
}
}

