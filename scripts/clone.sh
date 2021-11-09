export $(grep -v '^#' settings.env | xargs -d '\n')

read -p "Prod db schema/user: " schema
 
read -s -p "Prod db password: " pwd
 
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

if [ ! -d "../dbdevops" ]; then
    mkdir ../dbdevops
fi
cd ../dbdevops

export timestamp=$(($(date +%s%N)/1000000))
wget $prod_db_wallet_preauth -O wallet.zip

git checkout -b $timestamp-copy-prod

echo "*** CREATES $timestamp-copy-prod BRANCH TO REPO ***"

printf "set cloudconfig ./wallet.zip\nconn ${schema}/${pwd}@prod_high\ntables\nlb genschema -split\n${tablesconfig}\nexit" > gen.sql
sql /nolog @./gen.sql
rm -f gen.sql

if [ -n "${application_id}" ]; then
    printf "set cloudconfig ./wallet.zip\nconn ${schema}/${pwd}@prod_high\ntables\nlb genobject -type apex -applicationid ${application_id} -skipExportDate -expOriginalIds\nexit" > gen_apex.sql
    sql /nolog @./gen_apex.sql
    rm -f gen_apex.sql
fi

rm -f wallet.zip

git add .
git commit -m "prod copy at $timestamp"
git push origin $timestamp-copy-prod

git checkout master
