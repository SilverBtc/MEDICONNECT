#!/bin/bash
# A lancer sur SRV-WEB-PROD (192.168.30.12) et SRV-WEB-DEMO (ou meme VM en PoC)
# Usage: ./setup-web.sh prod|demo
set -e
MODE=$1
if [ "$MODE" != "prod" ] && [ "$MODE" != "demo" ]; then echo "Usage: $0 prod|demo"; exit 1; fi
sudo apt update && sudo apt install -y docker.io docker-compose-plugin openssl
sudo systemctl enable --now docker
DIR=$(dirname $0)
cd $DIR
mkdir -p certs
if [ "$MODE" = "prod" ]; then
  CN="portail.mediconnect.local"
  CRT="certs/prod.crt"; KEY="certs/prod.key"
else
  CN="demo.mediconnect.local"
  CRT="certs/demo.crt"; KEY="certs/demo.key"
fi
if [ ! -f "$CRT" ]; then
  openssl req -x509 -nodes -days 825 -newkey rsa:2048 -keyout $KEY -out $CRT -subj "/CN=$CN/O=MediConnect"
  echo "Cert auto-signe genere pour $CN (labo). En prod: Let's Encrypt via HAProxy ACME."
fi
sudo docker compose up -d
sudo docker ps
echo "OK $MODE. Test: curl -k https://localhost/ (prod) ou https://localhost:8443/ (demo)"
