export $(grep -v '^#' settings.env | xargs -d '\n')
 
read -p "Task ID: " task_id

read -s -p "Dev db schema/user: " dev_db_pwd

cd ../terraform

export TF_VAR_dev_db_pwd=$dev_db_pwd
export TF_VAR_task_id=$task_id
export tf_state_file="${os_bucket_tf}task-${task_id}.state"
echo $tf_state_file
sed -i "s|OS_TF|${tf_state_file}|g" main.tf

terraform init > tf-init.out

echo "*** destroy any previous installs with a task id ${task_id} ***"
terraform destroy -auto-approve > tf_destroy.out
git push origin --delete $task_id-task

echo "*** LAUNCHES A DEV INSTANCE Dev${task_id} FROM REPO AND CREATES FEATURE BRANCH ${task_id}-task ***"
terraform apply -auto-approve > tf.out
export url="$(grep "autonomous_database_wallet_preauth =" tf.out | grep -o '".*"' | tr -d '"')"

cd ../dbdevops

wget $url -O wallet-$task_id
base64 --decode wallet-$task_id > wallet-$task_id.zip

git checkout -b $task_id-task
git add wallet-$task_id.zip
git commit -m "feature branch for task ${task_id}"
git push origin $task_id-task