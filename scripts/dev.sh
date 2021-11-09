cd terraform

export TF_VAR_dev_db_pwd=$dev_db_pwd
export TF_VAR_task_id=$task_id
export tf_state_file="${os_bucket_tf}task-${task_id}.state"
echo $tf_state_file
sed -i "s|OS_TF|${tf_state_file}|g" main.tf

terraform init > tf-init.out

echo "*** destroy any previous installs with a task id ***"
terraform destroy -auto-approve > tf_destroy.out
git push origin --delete $task_id-task

echo "*** LAUNCH A DEV INSTANCE FROM REPO WITH A TASK ID AND CREATE FEATURE BRANCH ***"
terraform apply -auto-approve > tf.out
export url="$(grep "autonomous_database_wallet_preauth =" tf.out | grep -o '".*"' | tr -d '"')"

cd ../dbdevops

wget $url -O wallet-$task_id
base64 --decode wallet-$task_id > wallet-$task_id.zip

git config --global user.email "mika.rinne@oracle.com"
git config --global user.name "Mika Rinne"
git checkout -b $task_id-task
git add wallet-$task_id.zip
git commit -m "feature branch for task ${task_id}"
git push origin $task_id-task