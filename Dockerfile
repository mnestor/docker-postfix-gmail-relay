FROM alpine:3.16.0

RUN apk add --no-cache postfix tzdata && \
      # main.cf
      postconf -e smtpd_banner="\$myhostname ESMTP" && \
      postconf -e maillog_file=/dev/stdout && \
      postconf -e relayhost=[smtp.gmail.com]:587 && \
      postconf -e smtp_sasl_auth_enable=yes && \
      postconf -e smtp_sasl_password_maps=lmdb:/etc/postfix/sasl_passwd && \
      postconf -e smtp_sasl_security_options=noanonymous && \
      postconf -e smtp_use_tls=yes && \
      postconf -e mynetworks="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16" && \
      sed -i -e 's/inet_interfaces = localhost/inet_interfaces = all/g' /etc/postfix/main.cf && \
      mkdir -p /var/log/supervisor

COPY run.sh /

RUN chmod +x /run.sh

EXPOSE 25

CMD ["/run.sh"]
