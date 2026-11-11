# OPNsense 26.1 — pare-feu fwIPphone

## Interfaces

| Interface | Nom | Adresse | Réseau VMware |
|---|---|---|---|
| em0 | WAN | DHCP (NAT vers Internet) | NAT |
| em1 | LAN_SERVER | 10.10.10.254/24 | VMnet9 |
| em2 | LAN_LONGUEUIL | 192.168.20.1/24 | VMnet10 |
| em3 | LAN_MONTREAL | 192.168.50.1/24 | VMnet11 |

## DHCP et DNS

- **Dnsmasq** (DHCP) actif sur les trois interfaces internes, DNS de Dnsmasq déplacé sur le port 53053.
- Plages : 192.168.20.50 à .150 (Longueuil), 192.168.50.50 à .150 (Montréal), à partir de 10.10.10.41 (LAN_SERVER, PC-ADMIN).
- **Unbound** répond aux requêtes DNS sur le port 53.
- Le serveur Asterisk garde l'adresse fixe 10.10.10.10.

## Alias

| Nom | Type | Contenu |
|---|---|---|
| SRV_ASTERISK | Hôte | 10.10.10.10 |
| PORT_SIP | Port | 5061 (5060 en mode normal) |
| PORTS_RTP | Port | 10000:20000 |

## Règles de LAN_LONGUEUIL (ordre d'application)

| # | Action | Protocole | Source | Destination | Port | Nom de la règle |
|---|---|---|---|---|---|---|
| 1 | Autoriser | TCP | LAN_LONGUEUIL net | SRV_ASTERISK | PORT_SIP (5061) | ACL_VOIP_SIP (en TLS) |
| 2 | Autoriser | UDP | LAN_LONGUEUIL net | SRV_ASTERISK | PORTS_RTP | ACL_VOIP_RTP |
| 3 | Autoriser | TCP/UDP | LAN_LONGUEUIL net | LAN_LONGUEUIL address | 53 | DNS |
| 4 | Autoriser | ICMP | LAN_LONGUEUIL net | SRV_ASTERISK | – | Diagnostic |
| 5 | Bloquer | Tous | LAN_LONGUEUIL net | LAN_MONTREAL net | Tous | Isolement des sites (Log activé) |
| 6 | Bloquer | Tous | LAN_LONGUEUIL net | LAN_SERVER net | Tous | Aucun autre accès au serveur |
| 7 | Autoriser | Tous | LAN_LONGUEUIL net | Tous | Tous | Accès à Internet |

LAN_MONTREAL utilise les mêmes règles avec LAN_MONTREAL net comme source et LAN_LONGUEUIL net comme réseau bloqué.
OPNsense applique la **première règle qui correspond** : la règle ICMP doit rester au-dessus des blocages.

## Limiteur de trafic (Firewall → Shaper)

- **Pipe** PIPE_VOIP : 10 Mbit/s (valeur basse pour simuler un lien chargé)
- **Files** : Q_VOIX (poids 70), Q_SIP (poids 20), Q_DONNEES (poids 10)
- **Règles** : séquences 11 à 13 sur LAN_LONGUEUIL, 21 à 23 sur LAN_MONTREAL

| # | Classe | Trafic reconnu | File cible | Rôle |
|---|---|---|---|---|
| 1 | CLASS_RTP | UDP vers 10.10.10.10, ports 10000-20000 | Q_VOIX | Audio en priorité |
| 2 | CLASS_SIP | TCP vers 10.10.10.10, port 5061 | Q_SIP | Signalisation |
| 3 | class-default | Tout le reste | Q_DONNEES | Données |
