variable "name_prefix" {
  type        = string
  default     = ""
  description = "(optional) This is the name prefix for every resource used in this project"
}

variable "region" {
  type        = string
  description = "(required) this is the repo region"
}