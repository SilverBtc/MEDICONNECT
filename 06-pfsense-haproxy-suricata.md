# pfSense: HAProxy + Suricata + syslog distant (remote-safe, sans couper WG)

## A. Syslog distant (2 min, sans risque)
- Site A: Status > System Logs > Settings > Enable Remote Logging: IP 192.168.50.10:514, UDP, cocher System, Firewall, DHCP, DNS, WireGuard, IPsec.
- Site B: pareil vers 192.168.50.10 (passe via IPsec déjà allow-all, OK).
- Vérif: sur SRV-LAN-A `tail -f /var/log/pfsense/pfsense.log` puis générer trafic (ping, connexion WG).

## B. Suricata contrôle applicatif (5 min, mode détection d'abord)
- System > Package Manager > Available: installer `suricata` sur pfSense A.
- Services > Suricata > Add interface WAN + DMZ, mode IDS (pas IPS bloquant au début pour ne pas te couper).
- Rules: activer ET Open + Snort GPLv2, catégories http, tls, ssh, scan.
- Test Kali WAN: `nmap -sV 192.168.1.140`, `nikto -h https://192.168.1.140` (si NAT) -> voir Alerts. Montrer en vidéo.
- Passer en IPS bloquant uniquement quand tu es chez toi.

## C. HAProxy frontal HTTPS (à faire chez toi de préférence, car touche WAN:443)
- Installer package `haproxy`.
- Frontend `front-patients`: bind WAN:443 ssl (cert ACME self-signed labo OK), ACL path_beg /medecin -> backend Keycloak (192.168.50.10:8080), default -> backend PROD (192.168.30.12:443 ssl verify none).
- Backend PROD: health check HTTPS, backend DEMO JAMAIS sur WAN (uniquement WG).
- Justification rapport: terminaison TLS centralisée, filtrage L7, masquage serveurs internes, patients sans accès SI.
- Si trop juste en temps: HAProxy optionnel, Nginx direct + NAT 443->.12 suffit pour valider "exposition sécurisée". Garde HAProxy comme bonus.

## D. Ne pas toucher maintenant
- Ne supprime pas Default allow LAN, ne resserre pas WG, ne passe pas Suricata en block. Tout ça = phase finale chez toi (voir 07).
