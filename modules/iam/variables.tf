variable "project" {
  type = string
}
variable "name_prefix" {
  type = string
}
variable "service_account" {
  type = list(any)
}

variable "permissions" {
  type = list(string)
}