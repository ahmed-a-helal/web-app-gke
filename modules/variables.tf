variable "name_prefix" {
  type        = string
  default     = ""
  description = "(optional) This is the name prefix for every resource used in this project"
}
variable "regions" {
  type        = list(string)
  description = "(required) this is the regions of the architecture"
}
variable "cidr_subnet" {
  type        = list(string)
  description = "This is the cidr range of the subnets"
}

variable "dockerfolder" {
  type = string
  default = "docker"
}
variable "manifests" {
  type = string
  default = "manifests"
}
variable "database_image_name" {
  type = string
  default = "mongo:1"
}
variable "frontend_image_name" {
  type = string
  default = "web:1"
}