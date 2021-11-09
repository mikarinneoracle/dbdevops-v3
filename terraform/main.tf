terraform {
  backend "http" {
    address = "OS_TF"
    update_method = "PUT"
  }
}