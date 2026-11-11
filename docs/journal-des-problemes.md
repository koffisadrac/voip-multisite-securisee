# Journal des problèmes rencontrés

Les 22 problèmes rencontrés pendant le projet, avec leur cause et la solution appliquée.

| Problème rencontré | Cause | Solution appliquée |
|---|---|---|
| Licences uck9 et securityk9 à « None » dans la colonne Current après leur activation | Une licence ne devient active qu'au redémarrage du routeur | write memory, puis reload ; vérification avec show version (Evaluation) |
| show ephone et show ip dhcp binding refusées ou vides | Commandes tapées sur le commutateur, alors que CME et le DHCP sont sur le routeur | Exécution des commandes sur R-Longueuil et R-MONTREAL |
| Aucun bail DHCP pour les PC, seulement pour les téléphones | PC laissés en adressage statique, réglage par défaut de Packet Tracer | Passage des PC en DHCP (Desktop → IP Configuration) |
| Bandwidth 0 kb/s dans la classe VOIX de R-Longueuil | Commande priority percent 33 absente sous class VOIX (présente sur R-MONTREAL) | Ajout de priority percent 33 sous class VOIX de R-Longueuil (correction identifiée grâce au test A10) |
| destination-pattern 2 au lieu de 2.. sur R-Longueuil | Motif saisi de façon incomplète | Correction en destination-pattern 2.. pour n'acheminer que les numéros 2xx vers Montréal |
| Compteur de la classe VOIX à 0 pendant un appel entre les sites | Packet Tracer simule l'appel sans générer de flux RTP sur le lien série | Politique vérifiée avec show policy-map ; marquage EF vérifié dans le Volet B (test B12) |
| Tunnel IPsec non établi (MM_NO_STATE) et ping entre les sites en échec | Ligne encryption aes 256 absente de la policy ISAKMP de R-MONTREAL : les deux politiques ne correspondaient pas | Ajout de encryption aes 256 et hash sha sur R-MONTREAL ; tunnel en QM_IDLE |
| Tunnel non déclenché par un ping lancé depuis le routeur | Le ping part de l'adresse WAN 10.0.0.1, absente de l'ACL 110 | Ping lancé depuis un PC de Longueuil, dont l'adresse fait partie de l'ACL 110 |
| clear crypto isakmp et show running-config interface refusées | Commandes non prises en charge par Packet Tracer | Utilisation de show crypto map et show running-config |
| PC-LGU sans adresse IP (169.254.0.122) | Dnsmasq n'écoutait que sur LAN_SERVER | Ajout de LAN_LONGUEUIL et LAN_MONTREAL dans les interfaces de Dnsmasq (onglet General) |
| PC-MTL sans adresse IP (169.254.111.28) | Aucune plage DHCP créée pour LAN_MONTREAL | Création de la plage 192.168.50.50 à .150 |
| apt update en échec sur le serveur (Temporary failure resolving) | Dossier /etc/netplan vide : ni passerelle ni DNS | Création de 50-cloud-init.yaml avec la passerelle 10.10.10.254 et les DNS |
| Sites web inaccessibles sur PC-ADMIN (ERR_NAME_NOT_RESOLVED) alors que ping 8.8.8.8 fonctionnait | Windows interrogeait un mauvais serveur DNS | Diagnostic avec nslookup vers 10.10.10.254 (réponse correcte), puis DNS de Windows remis sur OPNsense |
| Copier-coller impossible entre l'ordinateur hôte et les machines virtuelles | Fonction de copier-coller de VMware inactive malgré VMware Tools | Administration du serveur en SSH depuis PowerShell sur PC-ADMIN, et notes de configuration ouvertes dans la machine virtuelle |
| Commandes Linux refusées (missing operand, syntax error, guillemets) | Espaces manquants entre les arguments et guillemets typographiques introduits par le traitement de texte | Relecture de chaque commande et saisie de guillemets droits |
| Appel non répondu coupé au lieu d'aller à la messagerie (No application 'VoiceMail') | Conflit entre app_voicemail et ses variantes ODBC et IMAP ; lignes noload ajoutées dans la section [global], ignorées | Lignes noload déplacées dans la section [modules] de modules.conf |
| Message d'accueil (*99) non rejoué | Appel raccroché pendant l'enregistrement | Fin de l'enregistrement avec la touche # |
| fail2ban ne bannissait pas malgré plusieurs échecs (Total failed : 0), puis refusait de démarrer | Surveillance du journal systemd par défaut sur Ubuntu 24.04 ; ensuite, logpath introuvable | backend = polling et logpath = /var/log/asterisk/messages.log, configuration testée avec fail2ban-client -t |
| tracert bloqué dès le premier saut | ICMP bloqué par la règle vers LAN_SERVER ; la règle ICMP ajoutée était placée sous les blocages | Règle ICMP déplacée au-dessus des règles de blocage |
| Section [endpoint-base] en double dans pjsip.conf après l'ajout de tos=cs3 | Extrait de configuration recopié en entier, avec une ligne « … » invalide | Lignes en trop supprimées, Asterisk redémarré ; 14 postes rechargés (pjsip show endpoints) |
| grep sur pjsip.conf refusé (Permission denied) | Fichier protégé en 640 (root:asterisk) parce qu'il contient les mots de passe | Commande relancée avec sudo |
| Paquet TLS du 105 bloqué dans Live View juste après l'application des règles | Les connexions en cours sont réinitialisées ; un paquet tardif de l'ancienne connexion ne correspond plus à aucun état | Aucune action : MicroSIP a ouvert une nouvelle connexion, autorisée par ACL_VOIP_SIP |
