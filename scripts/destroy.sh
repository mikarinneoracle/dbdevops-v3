cd terraform

export TF_VAR_dev_db_pwd=dummy
export TF_VAR_task_id=$task_id
export tf_state_file="${os_bucket_tf}task-${task_id}.state"
echo $tf_state_file
sed -i "s|OS_TF|${tf_state_file}|g" main.tf

terraform init > tf-init.out

echo "*** DESTROY DEV WITH A TASK ID ***"
terraform destroy -auto-approve > tf_destroy.out

cd ../dbdevops

# This does not work with protected master branches! 
# Option is to keep the obsolete wallets and delete with a batch periodically
git config --global user.email "mika.rinne@oracle.com"
git config --global user.name "Mika Rinne"
git rm wallet-$task_id.zip # rm done in branch.sh (only accessible once)
git commit -m "wallet for dev task ${task_id} removed"
git push origin master

git push origin --delete $task_id-task
