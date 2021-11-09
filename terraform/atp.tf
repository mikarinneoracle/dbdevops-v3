resource "oci_database_autonomous_database" "devops_autonomous_database" {
  
  #Required
  admin_password           = var.dev_db_pwd
  compartment_id           = var.compartment_ocid
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1
  db_name                  = "${var.database_name}${var.task_id}"
  is_free_tier             = var.use_always_free
  
  #Optional
  db_workload                                    = "OLTP"
  display_name                                   = "${var.database_name}${var.task_id}"
  is_auto_scaling_enabled                        = false
  is_dedicated                                   = false
  is_preview_version_with_service_terms_accepted = false
  license_model                                  = "BRING_YOUR_OWN_LICENSE"
}
