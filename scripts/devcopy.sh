export $(grep -v '^#' settings.env | xargs -d '\n')
 
read -p "Task ID: " task_id

read -s -p "Dev${task_id} db password: " pwd

printf "\n"

read -p "Dev${task_id} db schema/user to be created: " schema

read -p "Apex app id (optional) to be copied: " application_id

if [ -n "${application_id}" ]; then
    read -p "Apex workspace to be created (leave blank if already exists): " wsname
fi

if [ ! -d "../dbdevops" ]; then
    mkdir ../dbdevops
fi

cd ../dbdevops

echo "*** COPYING FROM REPO TO Dev-${task_id} WITH A TASK ID ${task_id} ***"

git checkout $task_id-task

printf "set cloudconfig ./wallet-${task_id}.zip\nconn admin/${pwd}@dev${task_id}_high\n/\n" > upd.sql
printf "create user ${schema} identified by \"${schema}\"\n/\n" >> upd.sql
printf "GRANT CONNECT to ${schema};\n/\n" >> upd.sql
printf "conn ${schema}/${pwd}@dev${task_id}_high\n" > upd.sql
if [ -f "controller.xml" ]; then
   printf "lb update -changelog controller.xml\n" >> upd.sql
fi
if [ -f "data.xml" ]; then
   printf "lb update -changelog data.xml\n" >> upd.sql
fi
printf "\ntables\nexit" >> upd.sql

cat upd.sql

sql /nolog @./upd.sql
rm -f upd.sql

if [ -n "${wsname}" ]; then
    printf "begin\n" > upd_apex.sql
    printf "    for c1 in (select privilege\n" >> upd_apex.sql
    printf "             from sys.dba_sys_privs\n" >> upd_apex.sql
    printf "             where grantee = 'APEX_GRANTS_FOR_NEW_USERS_ROLE' ) loop\n" >> upd_apex.sql
    printf "        execute immediate 'grant '||c1.privilege||' to ${schema} with admin option';\n" >> upd_apex.sql
    printf "    end loop;\n" >> upd_apex.sql
    printf "commit;\n" >> upd_apex.sql
    printf "end;\n/\n\n" >> upd_apex.sql
    printf "begin\n" >> upd_apex.sql
    printf "    apex_instance_admin.add_workspace(\n" >> upd_apex.sql
    printf "       p_workspace_id   => null,\n" >> upd_apex.sql
    printf "       p_workspace      => '${wsname}',\n" >> upd_apex.sql
    printf "       p_primary_schema => '${schema}'\n" >> upd_apex.sql
    printf "     );\n" >> upd_apex.sql
    printf "     commit;\n" >> upd_apex.sql
    printf "end;\n/\n\n" >> upd_apex.sql
    printf "conn ${schema}/${pwd}@dev${task_id}_high\n\n" >> upd_apex.sql
    printf "begin\n" >> upd_apex.sql
    printf "    apex_util.set_security_group_id( apex_util.find_security_group_id( p_workspace => '${schema}'));\n" >> upd_apex.sql
    printf "    apex_util.create_user(\n" >> upd_apex.sql
    printf "        p_user_name               => '${schema}',\n" >> upd_apex.sql
    printf "        p_email_address           => 'dummy',\n" >> upd_apex.sql
    printf "        p_default_schema          => '${schema}',\n" >> upd_apex.sql
    printf "        p_allow_access_to_schemas => '${schema}',\n" >> upd_apex.sql
    printf "        p_web_password            => '${pwd}',\n" >> upd_apex.sql
    printf "        p_developer_privs         => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',\n" >> upd_apex.sql
    printf "        p_allow_app_building_yn   => 'y',\n" >> upd_apex.sql
    printf "        p_allow_sql_workshop_yn   => 'y',\n" >> upd_apex.sql
    printf "        p_allow_websheet_dev_yn   => 'y',\n" >> upd_apex.sql
    printf "        p_allow_team_development_yn   => 'y'\n" >> upd_apex.sql
    printf "    );\n" >> upd_apex.sql
    printf "    commit;\n" >> upd_apex.sql
    printf "end;\n/\nexit\n" >> upd_apex.sql

    cat upd_apex.sql
    
    sql /nolog @./upd_apex.sql
    rm -f upd_apex.sql
fi

if [ -n "${application_id}" ]; then
    printf "set cloudconfig ./wallet-${task_id}.zip\nconn ${schema}/${pwd}@dev${task_id}_high\nlb update -changelog f${application_id}.xml\nexit" > upd_apex.sql
    sql /nolog @./upd_apex.sql
    rm -f upd_apex.sql
fi

git checkout master
