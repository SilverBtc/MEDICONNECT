# 07 - Nettoyage firewall final (À FAIRE CHEZ TOI, sur place, jamais à distance)

Objectif: passer de allow-all labo à moindre privilège. Fais un backup avant: Diagnostics > Backup & Restore > Download.

## A. WG_TUNNEL (172.16.16.0/24) — remplacer tes 5 règles larges par:
1. Pass TCP/UDP WG net -> 192.168.50.10:8082 (CRM) — seulement si source 172.16.16.10 (commerciaux). Description: `WG-commerciaux -> CRM only`
   Astuce pfSense: Source = Single host 172.16.16.10
2. Pass TCP WG net -> 192.168.30.13:8443 (DEMO) — source 172.16.16.10
3. Pass TCP/UDP WG net -> This Firewall:53 (DNS) — OK garder
4. Pass TCP WG net -> 192.168.50.10:8080 (Keycloak account, pour enrollment MFA via tunnel) — sources WG net
5. Pass admin: 172.16.16.99 -> 192.168.50.1:443 + 192.168.70.1:443 + 192.168.1.70:8006 (Proxmox) — Description `WG-admin -> admin only`
6. Block WG net -> LAN subnets (anti accès direct SI)
7. Block WG net -> DMZ PROD 192.168.30.12:443 (les commerciaux ne touchent pas la PROD)
Conserve temporairement une règle admin en haut le temps des tests, puis désactive l'accès Proxmox via WG (risque hyperviseur exposé).

## B. LAN (192.168.50.0/24)
1. Supprimer: `* -> WAN address 51820` (inutile sur LAN) + `192.168.60.0/24 -> 192.168.50.0/24` (à déplacer vers WG/IPsec si encore utile)
2. Garder Anti-Lockout + Kippo-Graph 8080 si besoin
3. Ajouter avant le allow-all:
   - Pass LAN -> DMZ PROD 443 ? NON: employés n'ont pas besoin PROD publique, ils passent par Internet comme patients. Block par défaut.
   - Pass LAN -> 192.168.50.10:8082/8080 (CRM/Keycloak interne) OK
   - Pass LAN -> DNS pfSense + WAN 80/443 pour Internet
4. Désactiver (pas supprimer tout de suite): `Default allow LAN to any` IPv4+IPv6. Tester 10 min, puis supprimer.
5. Vérifier que LAN ne peut plus joindre: pfSense GUI depuis LAN ? Doit être BLOQUÉ (exigence: flux admin séparés). Admin uniquement via ADMIN 192.168.99.0/24 ou WG-admin .99.

## C. DMZ (192.168.30.0/24) — remettre en ordre strict haut->bas:
1. Block DMZ -> LAN subnets (anti-pivot) — garder en 1er
2. Block DMZ -> WG 172.16.16.0/24 + IPsec nets
3. Pass TCP/UDP DMZ -> pfSense DMZ:53 (DNS local, mieux que WAN)
4. Pass TCP DMZ -> WAN 80/443 (updates) — limiter si possible aux IP Ubuntu/Debian
5. Pass TCP SRV-PROD .12 -> LAN Keycloak 192.168.50.10:8080 ? Uniquement si OIDC réel, sinon BLOCK (pas de flux DMZ->LAN par défaut)
6. Block all DMZ -> any (finale)
7. SUPPRIMER: `allow * -> *` + `DMZ -> WAN 22` sortant (inutile, dangereux). Honeypot .10:2222 entrant reste géré par NAT WAN, pas par règle sortante.
DNS: passer en TCP+UDP (actuellement TCP seul).

## D. WAN
1. Garder: IPsec (restreindre ports UDP 500/4500 + ESP si tu veux être propre, actuellement `*` trop large mais fonctionnel), WireGuard UDP 51820
2. NAT 443 -> 192.168.30.12:443 (PROD) à créer pour patients. NAT 2222 -> .10:2222 documenté comme honeypot volontaire.
3. Supprimer à la fin: ICMP depuis pfSense2 (test uniquement).
4. Activer Suricata en mode block après tests.

## E. IPsec
Remplacer `* -> *` par: Pass 192.168.70.0/24 -> 192.168.50.10 (serveurs siège) ports 8082/8080 + ICMP pour tests. Resserre après vidéo si temps.

## Ordre d'exécution sur place
Backup > WG > DMZ > LAN (désactive allow-all en dernier) > WAN > test complet > Re-backup. Garde une console Proxmox ouverte (pas via WG) pour te débloquer.
