#!/bin/bash

export $(grep -v '^#' settings.env | xargs -d '\n')

read -p "Task ID: " task_id

read -p "This will delete any existing resources for task ID ${task_id} and create a new ones, type Y to continue: " answer
if [ "${answer}" != "Y" ]; then
    echo "OK, quitting."
    exit
fi

read -s -p "Dev${task_id} db password (to be used): " pwd

printf "\n"

read -s -p "Please type Dev${task_id} db password again: " pwd2

printf "\n"

if [ ${pwd} != ${pwd2} ]; then
    echo "Passwords didn't match, exiting."
    exit
fi

cd ../terraform

rm -rf .terraform
rm -rf .terraform.lock.hcl

export TF_VAR_tenancy_ocid=$tenancy_ocid
export TF_VAR_compartment_ocid=$compartment_ocid
export TF_VAR_dev_db_pwd=$pwd
export TF_VAR_task_id=$task_id

export tf_state_file="${os_bucket_tf}task-${task_id}.state"
#echo $tf_state_file

cp main.tf copy_main
sed -i "s|OS_TF|${tf_state_file}|g" main.tf

terraform init > tf-init.out

echo "*** destroy any previous installs with a task id ${task_id} ***"
terraform destroy -auto-approve > tf_destroy.out
tail -2 tf_destroy.out
git push origin --quiet --delete $task_id-task

echo "*** LAUNCHES A DEV INSTANCE Dev${task_id} FROM REPO AND CREATES FEATURE BRANCH ${task_id}-task ***"
terraform apply -auto-approve > tf.out
tail -2 tf.out
export url="$(grep "autonomous_database_wallet_preauth =" tf.out | grep -o '".*"' | tr -d '"')"
mv copy_main main.tf

if [ ! -d "../dbdevops" ]; then
    mkdir ../dbdevops
fi
cd ../dbdevops

git checkout -b $task_id-task

wget $url -q -O wallet-$task_id
base64 --decode wallet-$task_id > wallet-$task_id.zip
rm -f wallet-$task_id

git add wallet-$task_id.zip
git commit -m "feature branch for task ${task_id}"
git push origin $task_id-task

git checkout master