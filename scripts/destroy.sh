#!/bin/bash

export $(grep -v '^#' settings.env | xargs -d '\n')

read -p "Task ID: " task_id

read -p "This will delete any existing resources for task ID ${task_id}, type Y to continue: " answer
if [ "${answer}" != "Y" ]; then
    echo "OK, quitting."
    exit
fi

cd ../terraform

export TF_VAR_tenancy_ocid=$tenancy_ocid
export TF_VAR_region=$region
export TF_VAR_compartment_ocid=$compartment_ocid
export TF_VAR_dev_db_name=$dev_db_name
export TF_VAR_dev_db_pwd=dummy
export TF_VAR_task_id=$task_id

export tf_state_file="${os_bucket_tf}task-${task_id}.state"
echo $tf_state_file
cp main.tf copy_main
sed -i "s|OS_TF|${tf_state_file}|g" main.tf
#cat main.tf

terraform init > tf-init.out

echo "*** DESTROY Dev-${task_id} WITH A TASK ID ${task_id} ***"
terraform destroy -auto-approve > tf_destroy.out
tail -2 tf_destroy.out

mv copy_main main.tf

if [ ! -d "../dbdevops" ]; then
    mkdir ../dbdevops
fi
cd ../dbdevops

# This does not work with protected master branches! 
# Alternative option is to keep the obsolete wallets and delete with a batch periodically
git rm wallet-$task_id.zip
git commit -m "wallet for dev task ${task_id} removed"
git push origin master

git push origin --delete $task_id-task

git checkout master
