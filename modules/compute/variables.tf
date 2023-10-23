variable "name_prefix" {
  type        = string
  default     = ""
  description = "(optional) This is the name prefix for every resource used in this project"
}

variable "management_node_subnet" {
  type        = string
  description = "(required) this is the subnet of the managemnt nodes/instances"
}

variable "management_node_tags" {
  type        = list(any)
  default     = []
  description = "(optional) this is a list of tags that is attached to managemnt nodes/instances"
}

variable "management_node_service_account_email" {
  type        = string
  description = "(required) this is the service account id attached  that is attached to managemnt nodes/instances"
}
variable "gke_service_account_email" {
  type        = string
  description = "(required) this is the service account email attached to GKE cluster NodePool"
}
variable "gke_subnet" {
  type        = string
  description = "(required) this is the subnet of the gke"
}

# variable "trans_files" {
#   type        = string
#   default     = ""
#   description = "(optional) this is the zone of the managemnt nodes/instances"
# }

# variable "post_trans_script" {
#   type        = string
#   default     = ""
#   description = "(optional) this is the zone of the managemnt nodes/instances"
# }