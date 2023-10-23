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