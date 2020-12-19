trap exit TERM

if [ -z "$DOMAINS" ]
then
      echo "DOMAINS not set" && exit 1
fi
if [ -z "$EMAIL" ]
then
      echo "EMAIL not set" && exit 1
fi

while :
do
    mkdir -p /etc/letsencrypt/haproxy
    for i in $DOMAINS; do
        echo "Working on $i"
        certbot certonly --standalone -d $i --non-interactive --preferred-challenges http --agree-tos --email $EMAIL && \
        cat /etc/letsencrypt/live/$i/fullchain.pem /etc/letsencrypt/live/$i/privkey.pem > /etc/letsencrypt/haproxy/$i.pem
    done
    kill -s HUP 1   # Send signal to reload HAProxy certificates
    sleep 12h & wait $!
done
