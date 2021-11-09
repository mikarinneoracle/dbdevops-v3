cd dbdevops

wget $prod_db_wallet_preauth -O wallet.zip

echo "*** MERGE REPO MASTER TO PROD ***"
sed -i "s/SCHEMA/${prod_db_schema}/g" upd.sql
sed -i "s/PWD/${prod_pwd_pwd}/g" upd.sql
sed -i "s/CONN/prod_high/g" upd.sql
sed -i "s/WALLET/wallet.zip/g" upd.sql
cat upd.sql
sql /nolog @./upd.sql

if [ -n "${application_id}" ] &&  [ "${application_id}" != "-" ]; then
    sed -i "s/SCHEMA/${prod_db_schema}/g" upd_apex.sql
    sed -i "s/PWD/${prod_pwd_pwd}/g" upd_apex.sql
    sed -i "s/CONN/prod_high/g" upd_apex.sql
    sed -i "s/WALLET/wallet.zip/g" upd_apex.sql
    sed -i "s/APP_ID/${application_id}/g" upd_apex.sql
    cat upd_apex.sql
    sql /nolog @./upd_apex.sql
fi

git restore upd.sql
git restore upd_apex.sql
