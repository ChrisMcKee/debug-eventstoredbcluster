variable "ca_common_name" {}
variable "ca_valid_days" {
  type = number
}
#Certs

variable "subjects_common_names" {
  type = set(string)
}
variable "subjects_valid_days" {
  type = number
}