export $(grep -v '^#' settings.env | xargs -d '\n')

read -p "Task ID: " task_id

read -p "Dev db schema/user: " schema

read -s -p "Dev db password: " pwd

printf "\n"

read -p "Apex app id (optional): " application_id

read -p "Tables data (leave empty for all tables, N for no tables): " tables
if [ -n "${tables}" ] && [ "${tables}" != "n" ]; then
    export tablesconfig="lb data -object ${tables}"
else
    if [ "${tables}" == "n" ]; then
        export tablesconfig=""
    else
        export tablesconfig="lb data"
    fi    
fi

mkdir ../dbdevops #assuming we have this already, but just make sure
cd ..dbdevops

echo "*** ADD CHANGES FROM Dev${task_id} TO DEV FEATURE BRANCH ${task_id}-task ***"

git checkout $task_id-task

printf "set cloudconfig ./wallet-${task_id}.zip\nconn ${schema}/${pwd}@dev${task_id}_high\ntables\nlb genschema -split\n${tablesconfig}\nexit" > gen.sql
sql /nolog @./gen.sql
rm -f gen.sql

if [ -n "${application_id}" ]; then
    printf "set cloudconfig ./wallet-${task_id}.zip\nconn ${schema}/${pwd}@dev${task_id}_high\ntables\nlb genobject -type apex -applicationid ${application_id} -skipExportDate -expOriginalIds\nexit" > gen_apex.sql
    sql /nolog @./gen_apex.sql
    rm -f gen_apex.sql
fi

# git rm wallet-$task_id.zip # Let's keep the wallet for subsequential updates, removed in destroy for the master branch instead
git add .
git commit -m "feature branch for task ${task_id}"
git push origin $task_id-task

git checkout master