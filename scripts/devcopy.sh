export $(grep -v '^#' settings.env | xargs -d '\n')
 
read -p "Task ID: " task_id

read -p "Dev db schema/user: " schema

read -s -p "Dev db password: " pwd

printf "\n"

read -p "Apex app id (optional): " application_id

if [ ! -d "../dbdevops" ]; then
    mkdir ../dbdevops
fi

cd ../dbdevops

echo "*** COPYING FROM REPO TO Dev-${task_id} WITH A TASK ID ${task_id} ***"

git checkout $task_id-task

printf "set cloudconfig ./wallet-${task_id}.zip\nconn ${schema}/${pwd}@dev${task_id}_high\nlb update -changelog controller.xml\nlb update -changelog data.xml\ntables\nexit" > upd.sql

sql /nolog @./upd.sql
rm -f upd.sql

if [ -n "${application_id}" ]; then
    printf "set cloudconfig ./wallet-${task_id}.zip\nconn ${schema}/${pwd}@dev${task_id}_high\n@privileges.sql\nlb update -changelog f${application_id}.xml\nexit" > upd_apex.sql
    printf "declare l_workspace_id number;\nbegin\nl_workspace_id := apex_util.find_security_group_id (p_workspace => 'WORKSPACE_NAME');\napex_util.set_security_group_id (p_security_group_id => l_workspace_id);\nAPEX_UTIL.PAUSE(2);\nend;\n/" > privileges.sql
    sql /nolog @./upd_apex.sql
    rm -f upd_apex.sql
    rm -f privileges.sql
fi
