cd dbdevops

echo "*** COPY FROM REPO TO DEV WITH A TASK ID ***"

git config --global user.email "mika.rinne@oracle.com"
git config --global user.name "Mika Rinne"
git checkout $task_id-task
git merge MASTER

sed -i "s/SCHEMA/${dev_db_schema}/g" upd.sql
sed -i "s/PWD/${dev_db_pwd}/g" upd.sql
sed -i "s/CONN/dev${task_id}_high/g" upd.sql
sed -i "s/WALLET/wallet-${task_id}.zip/g" upd.sql

cat upd.sql
sql /nolog @./upd.sql

if [ -n "${application_id}" ] &&  [ "${application_id}" != "-" ]; then
    sed -i "s/SCHEMA/${dev_db_schema}/g" upd_apex.sql
    sed -i "s/PWD/${dev_db_pwd}/g" upd_apex.sql
    sed -i "s/CONN/dev${task_id}_high/g" upd_apex.sql
    sed -i "s/WALLET/wallet-${task_id}.zip/g" upd_apex.sql
    sed -i "s/APP_ID/${application_id}/g" upd_apex.sql
    cat upd_apex.sql
    sql /nolog @./upd_apex.sql
fi

git restore upd.sql
git restore upd_apex.sql
