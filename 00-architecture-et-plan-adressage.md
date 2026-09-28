# MediConnect — Architecture cible (sans coupure)

## 1. Existant confirmé
- Proxmox 1 noeud: 192.168.1.70 (vmbr0 = WAN lab 192.168.1.0/24)
- pfSense A WAN: 192.168.1.140, LAN: 192.168.50.1 (192.168.50.0/24), DMZ: 192.168.30.1 (192.168.30.0/24), WG: 172.16.16.1/24 (tun_wg0)
- pfSense B WAN: 192.168.1.71, LAN: 192.168.70.1 (192.168.70.0/24)
- IPsec: 192.168.50.0/24 <-> 192.168.70.0/24 OK
- WireGuard road-warrior OK sur Site A
- Ubuntu A sur LAN 192.168.50.0/24, Ubuntu B sur LAN 192.168.70.0/24, Kali sur WAN 192.168.1.0/24, Honeypot (Kippo/Cowrie) sur DMZ 192.168.30.10:2222

## 2. Cible à ajouter (sans toucher au firewall maintenant)
| Zone | Subnet | GW pfSense | VMs / IPs | Confiance |
|---|---|---|---|---|
| WAN lab | 192.168.1.0/24 | - | Proxmox .70, pfA .140, pfB .71, Kali DHCP | 0 - non fiable |
| LAN A siège | 192.168.50.0/24 | 192.168.50.1 | SRV-LAN-A .10 (CRM+Keycloak+Logs), PC-A DHCP .100+ | 3 - interne |
| LAN B | 192.168.70.0/24 | 192.168.70.1 | SRV-LAN-B .10 (Ubuntu B existant), PC DHCP | 3 - interne |
| DMZ publique | 192.168.30.0/24 | 192.168.30.1 | SRV-WEB-PROD .12:443, Honeypot .10:2222 + 8080 Kippo-Graph | 1 - exposée, filtrage strict |
| DEMO (cible finale, à créer chez toi) | 192.168.31.0/24 | 192.168.31.1 (OPT) | SRV-DEMO .10:443 | 1 - exposée, isolée de PROD |
| TEMP DEMO (pour déployer à distance sans nouveau bridge) | 192.168.30.0/24 | 192.168.30.1 | SRV-WEB-DEMO .13:443 sur même bridge, isolation logique Docker + règle anti PROD->DEMO | 1 - transitoire, à migrer |
| ADMIN (cible finale, chez toi) | 192.168.99.0/24 | 192.168.99.1 (OPT) | Bastion .10 | 4 - max, isolée |
| WG_TUNNEL | 172.16.16.0/24 | 172.16.16.1 | commerciaux .10, support .20, admin .99 (IP fixe = identité) | 2 - authentifié |

Principe: Profil = IP WG fixe + règles firewall. Valide selon guide section 4. WireGuard ne fait pas RADIUS nativement, donc on justifie: pas de FreeRADIUS pour WG, identité portée par clé + IP fixe + Keycloak au niveau applicatif.

## 3. VMs à créer sur Proxmox (tout en vmbr existants, sans coupure)
1. SRV-WEB-PROD: LXC Debian12 ou VM Ubuntu 22.04, 1 vCPU/1Go/8Go, bridge DMZ (celui qui porte 192.168.30.0/24), IP 192.168.30.12/24 GW 192.168.30.1
2. SRV-WEB-DEMO (temporaire): peut être 2e container Docker sur même VM .12 pour économiser, ou 2e VM .13 même bridge. Recommandé: même VM, 2 containers (prod:443, demo:8443) pour démo immédiate.
3. Utiliser SRV-LAN-A existant (Ubuntu A 192.168.50.x): ajouter Docker pour CRM + Keycloak + rsyslog. Pas de nouvelle VM. Vérifie RAM: Keycloak veut 2Go mini. `free -h` — si <3Go libre, crée SRV-LOG séparé.
4. Ne crée DEMO 192.168.31.0/24 + ADMIN 192.168.99.0/24 que quand tu es chez toi: Proxmox Datacenter > Node > Network > Create Linux Bridge (sans port physique, VLAN aware si besoin) + ajouter vNIC aux pfSense + assigner OPT.

## 4. Ordre déploiement remote-safe
1. SRV-WEB PROD/DEMO (dossier 01-02)
2. CRM Dolibarr (dossier 03)
3. Keycloak MFA médecins (dossier 04)
4. Logs rsyslog + Suricata (dossier 05-06)
5. Chez toi: créer bridges DEMO/ADMIN + migrer container demo + nettoyage firewall + tests finaux (dossier 07)
