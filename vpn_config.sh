#!/bin/bash

# Répertoire de travail
WORKDIR=$(pwd)

# Fichiers
CSV_FILE="$WORKDIR/wilders.csv" # Fichier contenant les informations des Wilders
IP_FILE="$WORKDIR/ip.txt" # Fichier pour suivre les adresses IP attribuées
TEMPLATE_FILE="$WORKDIR/template-procedure.md" # Modèle de procédure pour les élèves
OUTPUT_DIR="$WORKDIR/output" # Répertoire de sortie pour les fichiers générés

# Informations WireGuard
SERVER_PUBLIC_KEY="KyD5aC8qZaZqNJ53wtg4s2vJOyEwo5HrGAGUjE7+qQQ=" # Clé publique su serveur VPN, à récupérer sur le firewall pfSense
SERVER_TUNNEL_IP="172.31.255.254/32" # Adresse IPv4 de l'interface VPN du serveur (utiliser un /32)
VPN_SUBNET="192.168.50.0/24" # Sous-réseau accessible via le VPN
VPN_ENDPOINT_IP="144.76.100.132" # Adresse IPv4 publique du serveur WireGuard (Ton Proxmox)
TUNNEL_MASK="/16" # Masque de réseau pour les interfaces du tunnel WireGuard
DNS="192.168.50.254" # Adresse de l'interface LAN de pfsense, pour que les clients VPN l'utilisent comme premier serveur DNS

# Variables réseau
BASE_IP="172.31" # Base pour les adresses VPN (172.31.x.y)
