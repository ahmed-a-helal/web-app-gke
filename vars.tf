variable "project" {
  type = string
}
variable "name_prefix" {
  type = string
}
variable "region" {
  type = list(string)
}
variable "cidr_subnet" {
  type = list(string)
}

variable "dockerdir" {
  type    = string
  default = "docker"
}
variable "kubernetisdir" {
  type    = string
  default = "manifests"
}
variable "helmdir" {
  type    = string
  default = "helm"
}
variable "alpine_image_name" {
  type    = string
  default = "alpine:1"
}
variable "database_image_name" {
  type    = string
  default = "mongo:1"
}
variable "frontend_image_name" {
  type    = string
  default = "web:1"
}