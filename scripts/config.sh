#!/bin/bash

read -p "Tenancy OCID: " tenancy

read -p "Region name: " region

read -p "Compartment OCID for ATP: " compartment

read -p "Development database instance name prefix (e.g. Dev): " dev_name

read -p "Terraform statefiles bucket preauth (object storage PAR with read/write access): " bucket

if [ -f "settings.env" ]; then
    read -p "Overwrite existing settings.env ? (Y to continue, backup will be taken): " answer
    if [ "${answer}" != "Y" ]; then
        echo "OK, quitting."
        exit
    fi
    cp settings.env settings.env.backup 
fi

printf "tenancy_ocid=${tenancy}\nregion=${region}\ncompartment_ocid=${compartment}\nos_bucket_tf=${bucket}\ndev_db_name=${dev_name}\n" > settings.env

echo "Config saved to settings.env"
