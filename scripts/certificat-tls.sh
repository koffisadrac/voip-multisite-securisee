#!/bin/bash
# Certificat autosigne pour SIP over TLS (laboratoire seulement)
# La cle privee generee ne doit jamais etre publiee.
mkdir -p /etc/asterisk/keys && cd /etc/asterisk/keys
openssl req -x509 -newkey rsa:2048 -nodes -days 825 \
  -keyout asterisk.key -out asterisk.crt \
  -subj "/O=abcServices/CN=10.10.10.10" \
  -addext "subjectAltName=IP:10.10.10.10"
chown -R asterisk:asterisk /etc/asterisk/keys
chmod 600 asterisk.key
