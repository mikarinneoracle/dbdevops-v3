output "autonomous_database_wallet_password" {
  value = random_string.autonomous_database_wallet_password.result
}

output "autonomous_database_wallet_preauth" {
  value ="https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.devops_wallet_preauth.access_uri}"
}
