variable "project" {
  type = string
}
variable "remote_bucket_credentials" {
  type = string
  default = null
  description = "is file path to the Service Account key used for the remote bucket access "
}
variable "terraform_access_key" {
  type = string
  default = null
  description = "is the path to the Service Account Key used by terrafrom to authenticate to gcp and authorize to create and delete the infra"
}

variable "name_prefix" {
  type = string
  description = "is the prefix name for all resources created by terraform"
}
variable "region" {
  type = list(string)
  description = "is a list of 2 inputs of the 2 regions created by this project anymore will be discarded"
}
variable "cidr_subnet" {
  type = list(string)
  default = ["172.16.0.0/29", "172.16.128.0/29"]
  description = "is the cidr range for the 2 subnets"
}

variable "dockerdir" {
  type    = string
  default = "docker"
  description = "is the path to the kubernetis directory where manifest files are created"
}
variable "kubernetisdir" {
  type    = string
  default = "manifests"
  description = "is the path to the kubernetis directory where manifest files are created"
}
variable "helmdir" {
  type    = string
  description = "the helm path for the script to use when deploying to the server (is prioritized over kubernetisdir)"
  default = ""
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