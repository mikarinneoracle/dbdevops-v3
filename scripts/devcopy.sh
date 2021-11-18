#!/bin/bash

export $(grep -v '^#' settings.env | xargs -d '\n')
 
read -p "Task ID: " task_id

read -s -p "Dev${task_id} db password: " pwd

printf "\n"

read -p "Create a new Dev${task_id} db schema/user (Y for yes) : " answer
if [ "${answer}" == "Y" ]; then
    read -p "New schema/user name (ADMIN not allowed): " schema
    if [ $schema == "ADMIN" ] || [ $schema == "admin" ]; then
        echo "New schema $schema allowed. Exiting.";
    fi
else
    read -p "Existing schema/user name: " schema
fi

read -p "Apex workspace to be created (optional): " wsname

read -p "Apex app id to be copied (optional): " application_id

if [ ! -d "../dbdevops" ]; then
    mkdir ../dbdevops
fi

cd ../dbdevops

echo "*** COPYING FROM REPO TO Dev-${task_id} WITH A TASK ID ${task_id} ***"

git checkout $task_id-task

printf "set cloudconfig ./wallet-${task_id}.zip\n" > upd.sql

if [ "${answer}" == "Y" ]; then
    printf "set cloudconfig ./wallet-${task_id}.zip\nconn admin/${pwd}@dev${task_id}_high\n/\n" >> upd.sql
    printf "create user ${schema} identified by \"${pwd}\"\n/\n" >> upd.sql
    printf "GRANT CONNECT, CREATE SESSION, CREATE CLUSTER, CREATE DIMENSION, CREATE INDEXTYPE, CREATE JOB, CREATE MATERIALIZED VIEW, CREATE OPERATOR, CREATE PROCEDURE, CREATE SEQUENCE, CREATE SYNONYM, CREATE TABLE, CREATE TRIGGER, CREATE TYPE, CREATE VIEW to ${schema};\n" >> upd.sql
    printf "ALTER USER ${schema} quota unlimited on DATA;\n/\n" >> upd.sql
fi

printf "conn ${schema}/${pwd}@dev${task_id}_high\n" >> upd.sql
if [ -f "controller.xml" ]; then
   printf "lb update -changelog controller.xml\n" >> upd.sql
else
    echo "Controller.xml not found. Schema not copied to Dev${task_id} ${schema}."
fi
if [ -f "data.xml" ]; then
   printf "lb update -changelog data.xml\n" >> upd.sql
else
    echo "Data.xml not found. Data not copied to Dev${task_id} ${schema}."
fi
printf "\ntables\nexit" >> upd.sql

sql /nolog @./upd.sql
rm -f upd.sql

if [ -n "${wsname}" ]; then
    printf "set cloudconfig ./wallet-${task_id}.zip\nconn admin/${pwd}@dev${task_id}_high\n/\n" > upd_apex.sql
    printf "begin\n" >> upd_apex.sql
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
    printf "        p_email_address           => 'dummy@oracle.com',\n" >> upd_apex.sql
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
    sql /nolog @./upd_apex.sql
    rm -f upd_apex.sql
fi

if [ -n "${application_id}" ]; then
    if [ -f "f${application_id}.xml" ]; then
        echo "Copying application ${application_id} to ${schema}."
        printf "declare\nl_workspace_id number;\nbegin\n" > upd_apex_privs.sql;
        printf "l_workspace_id := apex_util.find_security_group_id (p_workspace => 'WORKSPACE_NAME');\n" >> upd_apex_privs.sql;
        printf "apex_util.set_security_group_id (p_security_group_id => l_workspace_id);\n" >> upd_apex_privs.sql;
        printf "APEX_UTIL.PAUSE(2);\n" >> upd_apex_privs.sql;
        printf "end;\n/\n" >> upd_apex_privs.sql;

        printf "set cloudconfig ./wallet-${task_id}.zip\nconn ${schema}/${pwd}@dev${task_id}_high\n@upd_apex_privs.sql\nlb update -changelog f${application_id}.xml\nexit" > upd_apex.sql
        
        sql /nolog @./upd_apex.sql
        rm -f upd_apex.sql
        rm -f upd_apex_privs.sql
    else
        echo "${application_id} not found. Not copied to Dev${task_id} ${schema}."
    fi
fi

git checkout master
