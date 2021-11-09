export $(grep -v '^#' settings.env | xargs -d '\n')

read -p "This will copy changes from repo to prod, type Y to continue: " answer
if [ "${answer}" != "Y" ]; then
    echo "OK, quitting."
    exit
fi

read -p "Prod db schema/user: " schema
 
read -s -p "Prod db password: " pwd
 
printf "\n"
 
read -p "Apex app id (optional): " application_id

mkdir ../dbdevops #assuming we have this already, but just make sure
cd ../dbdevops

wget $prod_db_wallet_preauth -O wallet.zip

echo "*** MERGE REPO MASTER TO PROD ***"

printf "set cloudconfig ./wallet.zip\nconn ${schema}/${pwd}@prod_high\nlb update -changelog controller.xml\nlb update -changelog data.xml\ntables\nexit" > upd.sql

sql /nolog @./upd.sql
rm -f upd.sql

if [ -n "${application_id}" ]; then
    printf "set cloudconfig ./wallet.zip\nconn ${schema}/${pwd}@prod_high\n@privileges.sql\nlb update -changelog f${application_id}.xml\nexit" > upd_apex.sql
    sql /nolog @./upd_apex.sql
    rm -f upd_apex.sql
fi
