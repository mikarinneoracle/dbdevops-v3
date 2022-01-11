#!/bin/bash

read -p "Tenancy OCID: " tenancy

read -p "Region name: " region

read -p "Compartment OCID: " compartment

read -p "Production database instance name: " name

read -p "Production database database name (if not $name) : " dbname

if [ -z $dbname ]; then
   export $dbname=$name
fi

read -p "Development database instance name prefix (e.g. Dev): " dev_name

read -p "${name} database wallet preauth (in object storage): " preauth

read -p "Terraform statefiles bucket (in object storage with read/write access): " bucket

if [ -f "settings.env" ]; then
    read -p "Overwrite existing settings.env ? (Y to continue, backup will be taken): " answer
    if [ "${answer}" != "Y" ]; then
        echo "OK, quitting."
        exit
    fi
    cp settings.env settings.env.backup 
fi

printf "prod_instance_name=${name}\nprod_dbname=${dbname}\nprod_db_wallet_preauth=${preauth}\ntenancy_ocid=${tenancy}\nregion=${region}\ncompartment_ocid=${compartment}\nos_bucket_tf=${bucket}\ndev_db_name=${dev_name}\n" > settings.env

echo "Config saved to settings.env"
