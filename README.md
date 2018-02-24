# docker-postfix-gmail-relay
A docker image that uses postfix as a relay through gmail. Useful to link to other images.

Fork/rewrite of [LyleScott/docker-postfix-gmail-relay](https://github.com/LyleScott/docker-postfix-gmail-relay) using the latest alpine instead of ubuntu 14.04 and with the added ability to load the password from a text file rather than environment variable to avoid exposing your gmail password to anyone who has permission to run "docker inspect".

NOTE: works with domains hosted by Google, also. ie, Google for Work.  Note that you MUST enable your account to accept logins from "less secure apps" for this to work.

## Configurables

```
SYSTEM_TIMEZONE = UTC or America/New_York (UTC is the default)
MYNETWORKS = "10.0.0.0/8 192.168.0.0/16 172.0.0.0/8" (this is the default)
EMAIL = gmail or google domain
EMAILPASS = password (is turned into a hash and this env variable is removed at boot)
```

EMAIL and EMAILPASS may also be added by creating a folder, saving them into a file named ``credentials`` in that folder, and binding that folder to ``/config``.  See below.

## Example
Create a file with desired credentials
```bash
mkdir /postfix-config
chmod 600 /postfix-config/credentials
vim /postfix-config/credentials
```

Populate credentials file as so, then save and quit.
```bash
EMAIL=myemail@gmail.com
EMAILPASS=mypasswordhere
```

```bash
docker create \
    --name gmailrelay \
    -h your.desired.fqdn.com \
    -e SYSTEM_TIMEZONE="America/New_York" \
    -p 25:25 \
    -v /postfix-config:/config \
    postfix-gmail-relay

docker start postfix-gmail-relay
```

You can use netcat to test.  After the final ".", press "enter" to send the message.  Regardless of the "from" address you use here, the email will arrive "from" the email you used to create this docker container.

```bash
nc localhost 25
HELO smtp.test.lan
MAIL FROM:mytest@myfqdn.com
RCPT TO:youremail@gmail.com
DATA
this is a test message
.

```
