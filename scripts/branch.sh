cd dbdevops

echo "*** ADD CHANGES TO DEV FEATURE BRANCH TO REPO ***"

git config --global user.email "mika.rinne@oracle.com"
git config --global user.name "Mika Rinne"
git checkout $task_id-task

sed -i "s/SCHEMA/${dev_db_schema}/g" gen.sql
sed -i "s/PWD/${dev_db_pwd}/g" gen.sql
sed -i "s/CONN/dev${task_id}_high/g" gen.sql
sed -i "s/WALLET/wallet-${task_id}.zip/g" gen.sql
if [ -n "${tables}" ] &&  [ "${tables}" != "-" ] &&  [ "${tables}" != "n" ]; then
    sed -i "s/TABLECONFIG/lb data -object ${tables}/g" gen.sql
else
    if [ "${tables}" == "n" ]; then
        sed -i "s/TABLECONFIG//g" gen.sql
    else
        sed -i "s/TABLECONFIG/lb data/g" gen.sql
    fi    
fi

cat gen.sql
sql /nolog @./gen.sql

if [ -n "${application_id}" ] &&  [ "${application_id}" != "-" ]; then
    sed -i "s/SCHEMA/${dev_db_schema}/g" gen_apex.sql
    sed -i "s/PWD/${dev_db_pwd}/g" gen_apex.sql
    sed -i "s/CONN/dev${task_id}_high/g" gen_apex.sql
    sed -i "s/WALLET/wallet-${task_id}.zip/g" gen_apex.sql
    sed -i "s/APP_ID/${application_id}/g" gen_apex.sql
    cat gen_apex.sql
    sql /nolog @./gen_apex.sql
fi

# git rm wallet-$task_id.zip # Let's keep the wallet for subsequential updates
git restore gen.sql
git restore gen_apex.sql
git add .
git commit -m "feature branch for task ${task_id}"
git push origin $task_id-task
