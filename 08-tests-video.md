# 08 - Scénarios tests + trame vidéo 15 min

## Matrice succès / refus à filmer (1-1,5 min chacun)
| # | Test | Attendu | Commande / démo |
|---|---|---|---|
| T1 | Patient Internet -> PROD | OK HTTPS | Kali `curl -k https://192.168.30.12/` + navigateur portail PROD |
| T2 | Patient -> LAN interne | REFUS | Kali `curl -m 5 http://192.168.50.10:8082` timeout + log firewall Block |
| T3 | Commercial WG .10 -> CRM | OK | `curl http://192.168.50.10:8082` + login Dolibarr commercial01 |
| T4 | Commercial WG .10 -> PROD | REFUS | `curl -k -m 5 https://192.168.30.12/` timeout après durcissement |
| T5 | Commercial -> DEMO | OK | navigateur `https://192.168.30.13:8443` (ou .31.10 après migration) |
| T6 | Médecin MFA | OK + échec OTP | Keycloak login medecin01 + TOTP FreeOTP, puis mauvais code -> refus |
| T7 | IPsec A<->B | OK | Ubuntu-B `ping 192.168.50.10`, `ping 192.168.50.1` |
| T8 | DMZ -> LAN pivot | REFUS | depuis SRV-WEB `ping 192.168.50.10` bloqué + règle Anti-pivot hit |
| T9 | LAN -> admin pfSense | REFUS | depuis Ubuntu-A `curl -k https://192.168.50.1` bloqué après durcissement (montrer avant/après) |
| T10 | Kali scan WAN | Détecté | `nmap -sV 192.168.1.140` -> Suricata Alerts + rsyslog |

## Trame 15 min (Guide-Video)
- 0-1: contexte MediConnect, équipe, objectifs
- 1-3: schéma archi (montre 00-architecture + tableau zones/confiance). Zoome 150%, 1080p, OBS.
- 3-12: T1-T10 en direct, annonce chaque action à l'oral, pause 3s entre écrans
- 12-14: logs: `tail -f /var/log/pfsense/pfsense.log`, Suricata Alerts, Kippo-Graph :8080, `docker logs keycloak`
- 14-15: limites (1 noeud, WAN simulée, certs self-signed, DEMO transitoire même subnet, pas de Wazuh) + conclusion

## Checklist avant REC
- Micro testé (clap test, pic OBS), notifs OFF, terminal 18-20pt, navigateur 125-150%, script minuté imprimé
- Prépare onglets: pfSense A/B, Proxmox, PROD, DEMO, CRM, Keycloak, collecteur logs, Kali terminal
- Teste chaque T avant le REC définitif. Filme succès ET refus (exigé).
