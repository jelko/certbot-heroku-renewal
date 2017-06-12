#!/usr/bin/env sh

letsencrypt_live_dir=/etc/letsencrypt/live

if [ $(whoami) != "root" ]
then
    echo "Due to the default permissions of $letsencrypt_live_dir, this script must be executed as root."
    exit 1
fi

if [ ! -e ~/.netrc ]
then
    echo "Heroku auth token not found. Requesting credentials..."
    heroku login
fi

# hook/subcomand excecution (command defined in $1)
heroku_app=$2

if [ $1 = "auth-hook" ]
then
    domain=$CERTBOT_DOMAIN
    heroku config:set ACME_ENABLED=1 -a $heroku_app 2>&1
    heroku config:set ACME_RESPONSE="$CERTBOT_VALIDATION" -a $heroku_app 2>&1
    heroku config:set ACME_URL="$CERTBOT_TOKEN" -a $heroku_app 2>&1
    sleep 20 # wait for restart
    exit 0
fi

if [ $1 = "cleanup-hook" ]
then
    domain=$CERTBOT_DOMAIN
    heroku config:set ACME_ENABLED=0 -a $heroku_app 2>&1
    exit 0
fi

# normal excecution
domain=$1
heroku_app=$2

sudo certbot certonly -d $domain --manual --manual-auth-hook "$0 auth-hook $heroku_app" --manual-cleanup-hook "$0 cleanup-hook $heroku_app" --manual-public-ip-logging-ok

heroku certs:update $letsencrypt_live_dir/$domain/cert.pem \
    $letsencrypt_live_dir/$domain/privkey.pem \
    -a $heroku_app \
    --confirm $heroku_app
