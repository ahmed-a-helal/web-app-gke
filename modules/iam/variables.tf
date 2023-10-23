variable "name_prefix" {
  type = string
}
variable "service_accounts" {
  type = map(object({
    account_id  = string
    name        = string
    role_id     = string
    permissions = list(string)
  }))
}