resource "google_compute_network" "terravpc" {
  name = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "terra-sub1" {
  ip_cidr_range = var.sub_cidr
  name = var.sub_name
  network = google_compute_network.terravpc.id
  region = var.region_name
}


resource "google_compute_instance" "default" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone = var.zone
  boot_disk {
    initialize_params {
      image = var.image
    }
  }


  network_interface {
    subnetwork = google_compute_subnetwork.terra-sub1.self_link
#    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = "${file("startup.sh")}"

}

resource "google_compute_disk" "mydisk" {
  name = var.disk_name
  type = var.disk_type
  zone = google_compute_instance.default.zone
  physical_block_size_bytes = var.disk_size
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.mydisk.id
  instance = google_compute_instance.default.id
}