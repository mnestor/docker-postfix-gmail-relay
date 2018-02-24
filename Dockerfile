FROM alpine
USER root

RUN apk add --no-cache postfix rsyslog supervisor tzdata && \
# main.cf
postconf -e smtpd_banner="\$myhostname ESMTP" && \
postconf -e relayhost=[smtp.gmail.com]:587 && \
postconf -e smtp_sasl_auth_enable=yes && \
postconf -e smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd && \
postconf -e smtp_sasl_security_options=noanonymous && \
postconf -e smtp_use_tls=yes && \
postconf -e mynetworks="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16" && \
mkdir -p /var/log/supervisor

COPY supervisord.conf /etc/supervisor/
COPY init.sh /opt/init.sh

EXPOSE 25

CMD ["/opt/init.sh"]
