resource "google_compute_network" "terravpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "terra-sub1" {
  count         = length(var.region_name)
  ip_cidr_range = "10.1.${count.index}.0/24"
  name          = "${var.sub_name}-${count.index}"
  network       = google_compute_network.terravpc.id
  region        = var.region_name[count.index]
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.terravpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
}

resource "google_storage_bucket" "testbuck" {
  for_each = toset(var.region_name)
  name     = "goyal-${each.key}"
  location = each.key
}

data "google_compute_zones" "available" {
  count  = length(var.region_name)
  region = var.region_name[count.index]
}



resource "google_compute_instance" "default" {
  count        = length(data.google_compute_zones.available)
  //incomplete work
  name         = "my-vm-${each.key}"
  machine_type = var.machine_type
  zone         = each.key
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    #    subnetwork = google_compute_subnetwork.terra-sub1
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = file("startup.sh")

}

resource "google_compute_disk" "mydisk" {
  count                     = length(google_compute_instance.default)
  name                      = var.disk_name
  type                      = var.disk_type
  zone                      = google_compute_instance.default[count.index].zone
  physical_block_size_bytes = var.disk_size
}

resource "google_compute_attached_disk" "default" {
  count    = length(google_compute_instance.default)
  disk     = google_compute_disk.mydisk[count.index].id
  instance = google_compute_instance.default[count.index]
}
