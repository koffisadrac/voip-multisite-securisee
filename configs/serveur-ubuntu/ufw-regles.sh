#!/bin/bash
# Regles UFW finales du serveur Asterisk (mode chiffre)
ufw default deny incoming
ufw allow OpenSSH
# Signalisation SIP over TLS depuis les deux sites
ufw allow from 192.168.20.0/24 to any port 5061 proto tcp
ufw allow from 192.168.50.0/24 to any port 5061 proto tcp
# Audio RTP / SRTP depuis les deux sites
ufw allow from 192.168.20.0/24 to any port 10000:20000 proto udp
ufw allow from 192.168.50.0/24 to any port 10000:20000 proto udp
ufw enable
ufw status numbered
