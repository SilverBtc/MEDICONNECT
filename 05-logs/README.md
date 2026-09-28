# Collecteur syslog — procédure (SRV-LAN-A 192.168.50.10)

## Install
sudo apt install -y rsyslog
sudo cp 50-pfsense.conf /etc/rsyslog.d/50-pfsense.conf
sudo mkdir -p /var/log/pfsense && sudo chown syslog:adm /var/log/pfsense
sudo systemctl restart rsyslog
sudo ss -tulnp | grep 514

## Ouvrir firewall Ubuntu
sudo ufw allow 514/udp; sudo ufw allow 514/tcp
# ou si ufw inactif: rien à faire en labo, noter dans rapport.

## pfSense (sans risque, à faire à distance)
Site A + Site B: Status > System Logs > Settings:
- Enable Remote Logging: coché
- Source Address: LAN (ou Any)
- IP: 192.168.50.10, port 514, proto UDP
- cocher: System, Firewall, WireGuard, IPsec, DNS, DHCP
Save. Puis générer du trafic et vérifier:
tail -f /var/log/pfsense/pfsense.log

## Ce que tu montres en vidéo (30s)
1. `tail -f` sur collecteur
2. Depuis Ubuntu-B: `ping 192.168.50.10` via IPsec
3. Depuis Kali: `nmap` vers WAN -> alerte firewall loggée
4. Connexion Keycloak medecin01 -> log auth (montrer `docker logs keycloak`)

## Limites à écrire
Pas de SIEM lourd (Wazuh/Graylog) par choix simplicité. rsyslog + Suricata alerts + Cowrie logs suffisent pour PoC. Évolution: Wazuh single-node.
