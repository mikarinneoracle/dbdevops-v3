resource "oci_objectstorage_bucket" "devops" {

  #Required
  compartment_id = var.compartment_ocid
  name           = "dev${var.task_id}"
  namespace      = data.oci_objectstorage_namespace.user_namespace.namespace
  depends_on = [oci_identity_policy.devops_allow_object_storage_lifecycle]
}

resource "oci_objectstorage_object" "devops_wallet" {
  #Required
  bucket    = oci_objectstorage_bucket.devops.name
  content   = data.oci_database_autonomous_database_wallet.autonomous_database_wallet.content
  namespace = data.oci_objectstorage_namespace.user_namespace.namespace
  object    = "Wallet_dev${var.task_id}"
}

resource "oci_objectstorage_preauthrequest" "devops_wallet_preauth" {
  #Required
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.devops.name
  name         = "devops_atp_wallet_preauth"
  namespace    = data.oci_objectstorage_namespace.user_namespace.namespace
  time_expires = timeadd(timestamp(), "30m")

  #Optional
  object = oci_objectstorage_object.devops_wallet.object
}