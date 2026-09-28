# 09 - Plan rapport (exigences Projet-MediConnect.pdf)

1. Architecture retenue: schéma 2 sites + DMZ + DEMO + ADMIN + WG + IPsec. Justifier 1 noeud labo vs 2 sites réels.
2. Plan d'adressage: tableau 00-architecture (WAN lab, LAN A/B, DMZ, DEMO, ADMIN, WG 172.16.16.0/24). Justifier réutilisation 192.168.50/70 existants.
3. Zones + confiance: Internet 0, DMZ/DEMO 1, WG 2, LAN 3, ADMIN 4. Principe: plus exposé = filtrage strict.
4. VPN: IPsec P1/P2 entre .140<->.71 (réseaux 50<->70), WireGuard road-warrior 172.16.16.1, peers par profil IP fixe. Pourquoi pas OpenVPN+RADIUS: WG pas compatible RADIUS, identité via clé+IP+Keycloak.
5. Authentification: patients (HTTPS, compte local simulé), médecins (Keycloak realm mediconnect + TOTP), admins (pfSense TOTP + Keycloak admin + bastion). Captures QR/TOTP + échec OTP.
6. Filtrage: politique deny-by-default, tableaux règles finales WAN/LAN/DMZ/WG/IPsec (copier 07 après nettoyage). Montrer avant/après.
7. Règles identité: commerciaux .10 -> CRM+DEMO only, support .20, admin .99 -> ADMIN. Captures `wg show` + tests T3/T4.
8. Contrôle applicatif: Suricata IDS->IPS, HAProxy (ou NAT + justification si non fait), ET rules.
9. DMZ: PROD .12 isolée, pas de flux DMZ->LAN, updates via WAN 80/443 + DNS local, honeypot .10:2222 volontaire + Kippo-Graph.
10. Admin: VLAN/OPT 99 + bastion, LAN ne peut pas administrer, WG-admin séparé, MFA.
11. Journalisation: rsyslog 192.168.50.10:514, Suricata alerts, Keycloak events, Cowrie. Extraits logs.
12. Tests: matrice 08 (10 tests succès/refus).
13. Limites: WAN simulée même L2, certs self-signed, DEMO transitoire, pas de HA, pas de Wazuh, start-dev Keycloak, 1 noeud SPOF.
Annexes: `docker compose`, `wg show`, `ipsec status`, exports règles, liens vidéo Moodle.
