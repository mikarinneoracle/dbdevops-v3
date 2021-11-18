export $(grep -v '^#' settings.env | xargs -d '\n')

read -p "This will copy changes from repo to ${prod_instance_name}, type Y to continue: " answer
if [ "${answer}" != "Y" ]; then
    echo "OK, quitting."
    exit
fi

export name=$prod_instance_name

read -p "${name} db schema/user: " schema
 
read -s -p "${name} db password: " pwd
 
printf "\n"
 
read -p "Apex app id (optional): " application_id

read -p "Copy tables data (Y to copy): " answer

if [ ! -d "../dbdevops" ]; then
    mkdir ../dbdevops
fi
cd ../dbdevops

wget $prod_db_wallet_preauth -q -O wallet.zip

echo "*** COPY REPO MASTER TO ${name} ***"

printf "set cloudconfig ./wallet.zip\nconn ${schema}/${pwd}@${name}_high\n" > upd.sql

if [ -f "controller.xml" ]; then
   printf "lb update -changelog controller.xml\n" >> upd.sql
else
    echo "controller.xml not found. Not copied to ${prod_instance_name}." >> upd.sql
fi

if [ "${answer}" == "Y" ]; then
    if [ -f "data.xml" ]; then
       printf "lb update -changelog data.xml\n" >> upd.sql
    fi

    for filename in data*.xml; do
        [ -e "$filename" ] || continue
        if [ $filename != "data.xml" ]; then
           printf "lb update -changelog ${filename}\n" >> upd.sql
        fi
    done
fi

printf "\ntables\nexit" >> upd.sql

sql /nolog @./upd.sql
rm -f upd.sql

if [ -n "${application_id}" ]; then
    if [ -f "f${application_id}.xml" ]; then
        printf "set cloudconfig ./wallet.zip\nconn ${schema}/${pwd}@${name}_high\nlb update -changelog f${application_id}.xml\nexit" > upd_apex.sql
        sql /nolog @./upd_apex.sql
        rm -f upd_apex.sql
    else
        echo "f${application_id}.xml not found. App not copied to ${prod_instance_name}."
    fi
fi

rm -f wallet.zip
