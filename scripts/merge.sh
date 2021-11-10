export $(grep -v '^#' settings.env | xargs -d '\n')

read -p "This will copy changes from repo to prod, type Y to continue: " answer
if [ "${answer}" != "Y" ]; then
    echo "OK, quitting."
    exit
fi

export name=$prod_instance_name

read -p "${name} db schema/user: " schema
 
read -s -p "${name} db password: " pwd
 
printf "\n"
 
read -p "Apex app id (optional): " application_id

if [ ! -d "../dbdevops" ]; then
    mkdir ../dbdevops
fi
cd ../dbdevops

wget $prod_db_wallet_preauth -O wallet.zip

echo "*** MERGE REPO MASTER TO ${name} ***"

printf "set cloudconfig ./wallet.zip\nconn ${schema}/${pwd}@prod_high\nlb update -changelog controller.xml\nlb update -changelog data.xml\ntables\nexit" > upd.sql

sql /nolog @./upd.sql
rm -f upd.sql

if [ -n "${application_id}" ]; then
    printf "set cloudconfig ./wallet.zip\nconn ${schema}/${pwd}@prod_high\n@privileges.sql\nlb update -changelog f${application_id}.xml\nexit" > upd_apex.sql
    sql /nolog @./upd_apex.sql
    rm -f upd_apex.sql
fi
