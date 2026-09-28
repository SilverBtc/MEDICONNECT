# Keycloak MediConnect - setup MFA médecins (5 min, remote-safe)
# Sur SRV-LAN-A (192.168.50.10). RAM mini 2Go libres (`free -h`).

# 1. Lancement
# sudo apt install -y docker.io docker-compose-plugin
# cd 04-keycloak && sudo docker compose up -d
# Accès: http://192.168.50.10:8080 (via LAN ou via WG si règle WG->LAN OK, sinon via Proxmox console + SSH tunnel)

# 2. Realm MediConnect
# - Console admin (admin/Admin2026!) > Create Realm > `mediconnect` > Create
# - Realm Settings > Login > User registration OFF, Forgot password ON, Remember me ON
# - Authentication > OTP Policy: laisser TOTP 6 digits (défaut OK pour rapport)

# 3. Client espace médecin
# - Clients > Create client > Client ID `medecin-portal`, Type OpenID Connect, Root URL https://192.168.30.12/medecin
# - Valid redirect URIs: https://192.168.30.12/*  +  http://192.168.50.10:8080/*
# - Web origins: +
# Pour PoC vidéo: pas besoin d'intégration OIDC complète Nginx. Suffit de montrer:
#   login medecin01 + enrollment TOTP (FreeOTP/Google Authenticator) + OTP required à la 2e connexion.

# 4. Utilisateurs
# - Users > Add user > medecin01 (Email verified ON) > Create > Credentials > Set password `Medecin2026!` Temporary OFF
# - Authentication > Required actions > Configure OTP coché pour medecin01 (ou Realm > Authentication > OTP = required pour rôle médecin)
# - Créer groupe `medecins`, y mettre medecin01. Créer `commercial01`, `admin01` pour traçabilité.

# 5. Test vidéo (1 min)
# - Navigation privée > http://192.168.50.10:8080/realms/mediconnect/account > login medecin01/mdp > 1ère connexion propose QR TOTP > scanner > 2e login demande mdp + OTP. = MFA OK.
# - Montrer échec: mauvais OTP => "Invalid authenticator code".
# - Justifier rapport: médecins jamais d'accès réseau direct, uniquement HTTPS + MFA applicatif. Admins: même realm + TOTP pfSense (System > User Manager > TOTP).

# 6. Durcissement mini
# - Changer Admin2026! immédiatement après PoC.
# - Passer en start (prod) + TLS devant HAProxy quand HAProxy en place. Pour labo start-dev accepté, à noter en limites.
