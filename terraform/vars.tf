variable "tenancy_ocid" {
  type        = string
  description = "Tenancy ocid"
}

variable "region" {
  type        = string
  description = "Region name"
}

variable "compartment_ocid" {
  type        = string
  description = "Compartment ocid"
}

variable "num_nodes" {
  default = 1
}

variable "task_id" {
    type        = string
    description = "Input variable for the task id"
}

variable "dev_db_name" {
  type        = string
  description = "Dev db name"
}

variable "use_always_free" {
  default = false
}

variable "dev_db_pwd" {
    type        = string
    description = "Dev db pwd"
}
