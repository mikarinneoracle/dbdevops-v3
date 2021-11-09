variable "tenancy_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaat4zyuyyxbdcd4tbin3sx3vz3ac5pddqt2fzfvznmfgjarizah4ya" 
}

variable "region" {
  default = "eu-frankfurt-1" 
}

variable "compartment_ocid" {
  default = "ocid1.compartment.oc1..aaaaaaaae2fifpl73zspbqpiefzdgyj3zz6hn34ja54uggzwva5vlbftxkfq"
}

variable "num_nodes" {
  default = 1
}

variable "database_name" {
  default = "dev"
}

variable "use_always_free" {
  default = false
}

variable "task_id" {
    type        = string
    description = "Input variable for the task id"
}

variable "dev_db_pwd" {
    type        = string
    description = "Dev db pwd"
}
