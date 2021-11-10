read -p "Tenancy OCID: " tenancy

read -p "Compartment OCID: " compartment


read -p "Production database instance name: " name

read -p "${name} database wallet preauth (in object storage): " preauth

read -p "Terraform statefiles bucket (in object storage with read/write access): " bucket

printf "prod_instance_name=${name}\nprod_db_wallet_preauth=${preauth}\ntenancy_ocid=${tenancy}\ncompartment_ocid=${compartment}\nos_bucket_tf=${bucket}\n" > settings.env

echo "Config saved to settings.env"
