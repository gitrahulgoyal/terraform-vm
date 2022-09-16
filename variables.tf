variable "project_id" {}
variable "region_name" {
  type = list(string)
}
variable "machine_type" {}
variable "zone" {}
variable "image" {}
variable "vpc_name" {}
variable "sub_cidr" {}
variable "sub_name" {}
variable "disk_name" {}
variable "disk_type" {}
variable "disk_size" {}