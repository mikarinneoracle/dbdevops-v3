data "oci_objectstorage_namespace" "user_namespace" {
  compartment_id = var.compartment_ocid
}

resource "random_string" "autonomous_database_wallet_password" {
  length           = 16
  special          = true
  min_upper        = 3
  min_lower        = 3
  min_numeric      = 3
  min_special      = 3
  override_special = "{}#^*<>[]%~"
}

data "oci_database_autonomous_database_wallet" "autonomous_database_wallet" {
  autonomous_database_id = oci_database_autonomous_database.devops_autonomous_database.id
  password               = random_string.autonomous_database_wallet_password.result
  base64_encode_content  = "true"
}
