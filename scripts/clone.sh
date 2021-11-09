export $(grep -v '^#' settings.env | xargs -d '\n')
env

read -p "Prod db schema/user: " schema
 
read -s -p "Prod db password: " pwd
 
printf "\n"
 
read -p "Apex app id (optional): " application_id
if [ -z "${application_id}" ]; then
  export application_id=-
fi
 
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

mkdir ../dbdevops
cd ../dbdevops

export timestamp=$(($(date +%s%N)/1000000))
wget $prod_db_wallet_preauth -O wallet.zip

git config --global user.email $git_user 
git config --global user.name $git_email
git checkout -b $timestamp-copy-prod

echo "*** CREATES PROD COPY BRANCH TO REPO ***"

printf "set cloudconfig ./wallet.zip\nconn ${schema}/${pwd}@prod_high\ntables\nlb genschema -split\$tablesconfig\nexit" gen.sql
cat gen.sql
sql /nolog @./gen.sql
rm -f gen.sql

if [ -n "${application_id}" ] &&  [ "${application_id}" != "-" ]; then
    printf "set cloudconfig ./wallet.zip\nconn ${schema}/${pwd}@prod_high\ntables\nlb genobject -type apex -applicationid ${application_id} -skipExportDate -expOriginalIds\nexit" gen_apex.sql
    cat gen_apex.sql
    sql /nolog @./gen_apex.sql
    rm -f gen_apex.sql
fi

rm -f wallet.zip

git add .
git commit -m "prod copy at $timestamp"
git push origin $timestamp-copy-prod

cd ../scripts