variable "name_prefix" {
  type = string
}
variable "subnets" {
  type = map(object({
    name_suffix   = string
    ip_cidr_range = string
    region        = string
  }))
}

variable "vpc_description" {
  type    = string
  default = "This VPC is managed by terraform"
}