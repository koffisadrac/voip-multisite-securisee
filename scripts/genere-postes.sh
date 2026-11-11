#!/bin/bash
# Usage : sudo bash genere-postes.sh, puis :
#   chown root:asterisk /etc/asterisk/pjsip.conf /etc/asterisk/voicemail.conf
#   chmod 640 /etc/asterisk/pjsip.conf /etc/asterisk/voicemail.conf
# Les mots de passe et NIP generes restent sur le serveur (/root/comptes-sip.txt, chmod 600).
# Cree les postes 101-107 et 201-207 (PJSIP + messagerie vocale)
CONF=/etc/asterisk/pjsip.conf
VM=/etc/asterisk/voicemail.conf
LISTE=/root/comptes-sip.txt
: > "$LISTE"; chmod 600 "$LISTE"

for ext in {101..107} {201..207}; do
  if [ "$ext" -lt 200 ]; then site="LGU"; else site="MTL"; fi
  n=${ext: -1}
  pass=$(openssl rand -hex 8)
  pin=$(shuf -i 1000-9999 -n 1)
  echo "$ext  SIP: $pass  NIP: $pin" >> "$LISTE"
  cat >> "$CONF" <<EOF

[$ext](endpoint-base)
auth=$ext
aors=$ext
callerid="Agent $site $n" <$ext>
mailboxes=$ext@default

[$ext](auth-base)
username=$ext
password=$pass

[$ext](aor-base)
EOF
  echo "$ext => $pin,Agent $site $n" >> "$VM"
done
echo "Comptes enregistres dans $LISTE"
