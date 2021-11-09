resource "oci_identity_policy" "devops_allow_object_storage_lifecycle" {
  name           = "devops-object-family-${var.task_id}"
  description    = "policy created by terraform for devops"
  compartment_id = var.tenancy_ocid
  statements     = ["Allow service objectstorage-${var.region} to manage object-family in tenancy"]
}
