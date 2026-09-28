# CRM Dolibarr pour commerciaux (remote-safe, sur SRV-LAN-A 192.168.50.10)
# Pourquoi Dolibarr: open-source FR, 1 image Docker + MariaDB, login réel à montrer en vidéo. Pas besoin SuiteCRM/Odoo lourds.

# Lancement:
# cd 03-crm-dolibarr && sudo docker compose up -d
# Attendre 60s (init DB), puis http://192.168.50.10:8082
# Login init: admin / Admin2026!  (changer après)
# Créer user commercial01 (mdp Commer2026!) avec droits CRM uniquement.

# Publication:
# - En interne: http://192.168.50.10:8082 direct.
# - Pour commerciaux nomades via WG 172.16.16.10: autoriser WG->192.168.50.10:8082 uniquement (à ajouter lors du nettoyage final, pour l'instant ton allow-all WG laisse passer -> OK pour tests).
# - Ne JAMAIS publier CRM sur WAN. Commerciaux passent par WG uniquement. Démo devant médecins: utiliser DEMO 192.168.30.13:8443, pas la PROD.

# Test vidéo:
# 1. commercial WG (.10) -> http://192.168.50.10:8082 OK
# 2. commercial WG -> https://192.168.30.12 (PROD) REFUSE (à montrer après durcissement, ou via curl timeout)
# 3. Kali WAN -> http://192.168.50.10:8082 REFUSE (pas de NAT, pas de route)
