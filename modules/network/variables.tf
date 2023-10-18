variable "project" {
  type = string
}
variable "name_prefix" {
  type = string
}
variable "region" {
  type = string
}
variable "cidr_subnet" {
  type = string
}

variable "vpc_description" {
  type    = string
  default = "This VPC is managed by terraform"
}