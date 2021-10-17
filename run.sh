#!/bin/sh

# Load credentials
if [ -f /config/credentials ]; then
    echo "loading credentials from /config/credentials"
    source /config/credentials
fi

# Set timezone
if [ ! -z "${SYSTEM_TIMEZONE}" ]; then
    echo "configuring system timezone"
    echo "${SYSTEM_TIMEZONE}" > /etc/timezone
    cp /usr/share/zoneinfo/${SYSTEM_TIMEZONE} /etc/localtime
fi

# Set mynetworks for postfix relay
if [ ! -z "${MYNETWORKS}" ]; then
    echo "setting mynetworks = ${MYNETWORKS}"
    postconf -e mynetworks="${MYNETWORKS}"
fi

# General the email/password hash and remove evidence.
if [ ! -z "${EMAIL}" ] && [ ! -z "${EMAILPASS}" ]; then
    touch /etc/postfix/sasl_passwd
    chmod 600 /etc/postfix/sasl_passwd
    echo "[smtp.gmail.com]:587    ${EMAIL}:${EMAILPASS}" > /etc/postfix/sasl_passwd
    postmap /etc/postfix/sasl_passwd
    #rm /etc/postfix/sasl_passwd
    chmod 600 /etc/postfix/sasl_passwd.lmdb
    echo "postfix EMAIL/EMAILPASS combo is setup."
else
    if [ -f /etc/postfix/sasl_passwd.lmdb ]; then
        echo "EMAIL or EMAILPASS not set, but /etc/postfix/sasl_passwd.db already exists so it's safe to ignore"
    else
        echo "EMAIL or EMAILPASS not set!"
    fi
fi
unset EMAIL
unset EMAILPASS


#Start services

# If host mounting /var/spool/postfix, we need to delete old pid file before
# starting services
rm -f /var/spool/postfix/pid/master.pid

exec /usr/sbin/postfix -c /etc/postfix start-fg
