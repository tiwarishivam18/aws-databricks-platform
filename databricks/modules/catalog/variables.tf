variable "catalog_name" {
  type = string
}

variable "storage_root" {
  type = string
}

variable "schemas" {
  type = set(string)
}

variable "reader_group" {
  type = string
}
