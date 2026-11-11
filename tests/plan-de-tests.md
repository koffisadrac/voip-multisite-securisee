# Plan de tests

43 tests, chacun prouvé par une capture dans le [rapport](../docs/Rapport_VoIP_Kanga.pdf).

## Volet A — Cisco Packet Tracer

| # | Test | Commande ou action | Résultat attendu | Résultat obtenu |
|---|---|---|---|---|
| A1 | VLAN créés | show vlan brief (commutateurs) | VLAN 10/20 ou 40/50 actifs sur F0/1 à F0/7 | Réussi : VLAN 10/20 (Longueuil) et 40/50 (Montréal) actifs sur Fa0/1 à Fa0/7 |
| A2 | Trunk actif | show interfaces trunk | G0/1 en trunk, VLAN autorisés corrects | Réussi : Gig0/1 en trunking, VLAN 10,20 et 40,50 autorisés |
| A3 | Baux DHCP | show ip dhcp binding (routeurs) | PC en .10.x/.40.x, téléphones en .20.x/.50.x | Réussi : 14 baux par routeur, PC en .11 à .17 et téléphones en .11 à .17 de leur VLAN |
| A4 | Lien WAN | ping 10.0.0.2 depuis R-Longueuil et ping 10.0.0.1 depuis R-MONTREAL | 5/5 réussis | Réussi : 5/5 dans les deux sens (moyenne 13 ms et 15 ms) |
| A5 | Routage inter-sites | Ping d'un PC de Longueuil vers un PC de Montréal, et l'inverse | Réussi | Réussi : 4/4 réponses dans les deux sens, TTL 126 (deux routeurs traversés) |
| A6 | Enregistrement des téléphones | show ephone | 7 téléphones REGISTERED par site | Réussi : 7 téléphones REGISTERED par site (101 à 107 et 201 à 207) |
| A7 | Appel local | 101 appelle 103 ; 201 appelle 206 | « Connected » des deux côtés | Réussi : « Connected » des deux côtés |
| A8 | Appel inter-sites | 206 appelle 107 | « Connected » des deux côtés | Réussi : « Connected » des deux côtés |
| A9 | Appel inverse | 101 appelle 203 | « Connected » des deux côtés | Réussi : « Connected » des deux côtés |
| A10 | QoS appliquée | show policy-map interface s0/0/0 | Politique QOS_VOIP présente en sortie | Montréal : réussi (Strict Priority, 660 kb/s). Longueuil : priority percent 33 absente au premier essai, ajoutée ensuite (chapitre X). Compteurs à 0 : Packet Tracer ne génère pas de flux RTP |
| A11 | Accès SSH seulement | Telnet vers le routeur, puis ssh -l admin | Telnet refusé, SSH accepté | Réussi : Telnet fermé par le routeur, SSH accepté (Longueuil et Montréal) |

## Volet B — Asterisk et OPNsense (mode normal)

| # | Test | Action | Résultat attendu | Résultat obtenu |
|---|---|---|---|---|
| B1 | Enregistrement | pjsip show contacts | Postes enregistrés « Avail » | Réussi : 105 (192.168.20.147) et 202 (192.168.50.72) Avail, RTT 2 et 7 ms |
| B2 | Appel local | 101 appelle 105, on décroche | Conversation établie | Réussi : « Connected » sur MicroSIP |
| B3 | Appel inter-sites | 105 appelle 202, on décroche | Conversation établie | Réussi : le 202 sonne, décroche, conversation établie (simple_bridge) |
| B4 | Appel inverse | 202 appelle 105 | Conversation établie | Réussi : appel reçu et pris par le 105 |
| B5 | Pas de réponse | 105 appelle 202, personne ne décroche | Messagerie après 20 s, message enregistré | Réussi : après 20 s, VoiceMail(202@default,u) et annonce de la messagerie (après correction des modules) |
| B6 | Consultation | 202 compose *98 et son NIP | Le message de B5 est lu | Réussi : message lu ; la boîte 202 passe de 2 à 1 nouveau message |
| B7 | Message d'accueil | 202 compose *99, parle, puis # | Le message est rejoué | Réussi : Record, puis Playback du message bienvenue |
| B8 | File Longueuil | 202 compose 9000 | Accueil, musique, position annoncée, un agent LGU sonne | Réussi : accueil, musique d'attente, position annoncée, le 105 sonne et répond (erreurs normales pour les agents non connectés) |
| B9 | File Montréal | 105 compose 9001 | Un agent MTL sonne | Réussi : accueil, musique d'attente, l'agent de Montréal sonne et répond |
| B10 | Mauvais mot de passe | Faux mot de passe sur le compte 105 | Enregistrement refusé, tentative journalisée | Réussi : enregistrement refusé, « Failed to authenticate » dans messages.log |
| B11 | Bannissement | 5 tentatives ratées depuis la même machine | Adresse listée par fail2ban-client status asterisk | Réussi : 192.168.20.147 bannie (Currently banned: 1), puis débannie avec unbanip |
| B12 | Marquage QoS | tcpdump -ni ens33 -v -c 10 src host 10.10.10.10 and udp portrange 10000-20000 pendant un appel 105 ↔ 203 | tos 0xb8 (DSCP EF) sur les paquets audio | Réussi : tos 0xb8 (DSCP 46) sur les paquets audio envoyés par Asterisk vers les deux postes |

## Volet B — Routage et filtrage par OPNsense

| # | Test | Action | Résultat attendu | Résultat obtenu |
|---|---|---|---|---|
| B18 | Adresses DHCP | ipconfig sur PC-LGU et PC-MTL | Adresses dans la plage .50 à .150, passerelle en .1 | Réussi : PC-LGU en 192.168.20.x et PC-MTL en 192.168.50.x, passerelle .1 (après correction de Dnsmasq) |
| B19 | Routage vers le serveur | Depuis PC-LGU, tracert -d 10.10.10.10 | Passage par 192.168.20.1, puis arrivée au serveur | Réussi après ajout de la règle ICMP : 192.168.20.1, puis 10.10.10.10 |
| B20 | Isolement des sites | Depuis PC-LGU, ping vers l'adresse de PC-MTL | Échec : bloqué par la règle « Isolement des sites » | Réussi : Request timed out |
| B21 | Appel entre les sites | 105 (LAN_LONGUEUIL) appelle 203 (LAN_MONTREAL) | Conversation établie malgré l'isolement des sites | Réussi : 2 canaux actifs, 1 appel en cours (core show channels) |
| B22 | Journal du pare-feu | Firewall → Log Files → Live View pendant B20 et B21 | SIP et RTP de LAN_LONGUEUIL vers 10.10.10.10 autorisés | Réussi : trafic UDP vers 10.10.10.10 (SIP et RTP) autorisé (pass) sur LAN_LONGUEUIL |

## Chiffrement (volets A et B)

| # | Test | Commande ou action | Résultat attendu | Résultat obtenu |
|---|---|---|---|---|
| A12 | Tunnel IPsec établi | Ping d'un PC de Longueuil vers 192.168.40.15, puis show crypto isakmp sa | État QM_IDLE | Réussi : 10.0.0.1 ↔ 10.0.0.2, QM_IDLE, ACTIVE (après correction de la policy de R-MONTREAL) |
| A13 | Trafic chiffré | Ping entre les sites, puis show crypto ipsec sa | Compteurs #pkts encaps et #pkts decaps en hausse | Réussi : 7 paquets chiffrés (encaps) et 6 déchiffrés (decaps) entre 192.168.10.0/24 et 192.168.40.0/24 |
| B13 | Enregistrement TLS | pjsip show contacts | Contacts en transport=tls, port 5061, « Avail » | Réussi : 105 et 203 enregistrés avec transport=TLS, Avail |
| B14 | Signalisation illisible | tcpdump -ni ens33 -A -c 15 tcp port 5061 pendant un appel | Aucun message SIP lisible (« INVITE », « REGISTER ») | Réussi : 15 paquets TCP 5061 entre 192.168.20.72 et 10.10.10.10, contenu illisible ; aucun mot SIP (INVITE, REGISTER) visible |
| B15 | Audio chiffré | 105 appelle 203, avec pjsip set logger method INVITE | SDP en RTP/SAVP avec une ligne a=crypto, appel établi | Réussi : m=audio RTP/SAVP, a=crypto AES_CM_128_HMAC_SHA1_80, conversation établie |
| B16 | Écoute impossible | Capture ~/appel-chiffre.pcap ouverte dans Wireshark | Aucun appel à rejouer, contrairement à appel-clair.pcap | Réussi : 4558 paquets, aucun appel détecté (Appels VoIP vide), signalisation en TLS |
| B17 | Poste non chiffré refusé | Compte MicroSIP remis en UDP sans chiffrement | Enregistrement ou appel refusé | Réussi : compte 105 en UDP sans chiffrement → « Request Timeout » |
| B23 | Journal du pare-feu en mode chiffré | Firewall → Log Files → Live View sur LAN_LONGUEUIL pendant les appels chiffrés | TCP 5061 et UDP vers les ports RTP autorisés, aucun trafic sur 5060 | Réussi : TCP 5061 (TLS) et UDP 13327 à 18079 (SRTP) autorisés ; aucun trafic sur le port 5060 |

## Volet C — ACL, QoS et Wireshark

| # | Test | Filtre ou action | Résultat attendu | Résultat obtenu |
|---|---|---|---|---|
| C1 | ACL de signalisation | Enregistrement du 105 depuis PC-LGU, Live View filtré sur 5061 | Accepté par la règle 1 (ACL_VOIP_SIP, TCP 5061) | Réussi : TCP 5061 du 105 (192.168.20.72) et du 203 (192.168.50.147) vers 10.10.10.10 autorisé (pass) par ACL_VOIP_SIP. La seule ligne bloquée est un paquet tardif d'une connexion fermée lors de l'application des règles. |
| C2 | ACL de blocage | ping 192.168.50.147 depuis PC-LGU | Bloqué par la règle 5 (Isolement des sites) | Réussi : 4 paquets envoyés, 0 reçu (100 % de perte) |
| C3 | Signalisation SIP | appel-clair.pcap, Téléphonie → Appels VoIP → Flux séquence | INVITE, 401, INVITE, 100 Trying, 180 Ringing, 200 OK, ACK, puis BYE | Réussi : INVITE, 401, ACK, INVITE authentifié, 100 Trying, 180 Ringing, 200 OK, ACK, UPDATE, puis BYE et 200 OK ; codec G.711 µ-law |
| C4 | Flux audio RTP | appel-clair.pcap, Téléphonie → RTP → Flux RTP | Flux continus dans les deux sens, environ 50 paquets par seconde, codec G.711 | Réussi : 4 flux g711U de 6,28 s, tous par Asterisk ; 315 paquets par flux (un toutes les 20 ms), 0 % de perte, gigue inférieure à 0,05 ms |
| C5 | Marquage de l'audio | Paquet RTP envoyé par 10.10.10.10, champ Differentiated Services | DSCP 46 (EF), soit 0xb8 | Réussi : 0xb8, Expedited Forwarding (46), sur les 630 paquets RTP envoyés par Asterisk. |
| C6 | Marquage de la signalisation | tcpdump ci-dessus pendant un appel chiffré 105 ↔ 203 | tos 0x60 (DSCP 24, CS3) sur la signalisation TLS | Réussi : tos 0x60 sur les 10 paquets TLS envoyés par 10.10.10.10:5061 vers le 105 et le 203 |
| C7 | Priorité sous charge | Firewall → Shaper → Status pendant l'appel et le téléchargement | Appel compté dans Q_VOIX, téléchargement dans Q_DONNEES | Réussi : Q_VOIX 1,30 k paquets (270,8 ko), Q_SIP 145 paquets, Q_DONNEES 17,46 k paquets (11,4 Mo) dans PIPE_VOIP à 10 Mbit/s |
