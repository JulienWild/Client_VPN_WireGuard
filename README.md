<h1 align="center">
🛠️  Script d'automatisation de génération des configurations des clients VPN WireGuard - Guide pour les Formateurs
</h1>

## Table of contents

- [🚀 Bienvenue !](#-bienvenue-)
- [🏗️ Fonctionnalités principales](#️-fonctionnalités-principales)
- [📂 Préparation de l'environnement](#-préparation-de-lenvironnement)
- [📚 Structure du dépôt](#-structure-du-dépôt)
- [💻 Comment utiliser le script ?](#-comment-utiliser-le-script)
  - [🛠️ Étape 1 : Préparer l’environnement](#️-étape-1--préparer-lenvironnement)
  - [🛠️ Étape 2 : Lancer le script](#️-étape-2--lancer-le-script)
- [🎯 Résultat attendu](#-résultat-attendu)
- [📤 Transmission des fichiers aux élèves](#-transmission-des-fichiers-aux-élèves)
  - [📦 Étape 1 : Envoyer l'archive chiffrée (.tar.gz.gpg)](#-étape-1--envoyer-larchive-chiffrée-targzgpg)
  - [📜 Étape 2 : Transmettre la procédure et le mot de passe](#-étape-2--transmettre-la-procédure-et-le-mot-de-passe)
- [🚦 Procédures supplémentaires](#-procédures-supplémentaires)
  - [⛵ Ajout d'un nouvel équipage ?](#-ajout-dun-nouvel-équipage-)
  - [🆕 Réinitialiser complètement le script](#-réinitialiser-complètement-le-script)
  - [❌ Supprimer un seul élève](#-supprimer-un-seul-élève)
- [📬 En cas de problème ?](#-en-cas-de-problème-)


---

## 🚀 Bienvenue ! 

Ce script a été conçu pour automatiser la configuration des clients VPN **WireGuard** afin de simplifier le déploiement dans un contexte pédagogique. 

Il prend en charge :
- La **génération des clés publiques et privées** pour chaque wilder.
- La création d'une **procédure personnalisée** adaptée à chaque wilder.
- La génération d'une archive chiffrée contenant les clés et la procédure, protégée par un mot de passe.

Le script est conçu pour être utilisé dans des environnements **Linux** et **Windows**. 

---

## 🏗️ Fonctionnalités principales

### ✅ Ce que fait le script :
1. **Génération des clés WireGuard** :
   - Génère une clé publique et une clé privée pour chaque wilder déclaré dans un fichier.
2. **Création de la procédure utilisateur** :
   - Produit un fichier de procédure personnalisé au format Markdown (`.md`) contenant les informations nécessaires pour configurer le VPN.
3. **Chiffrement des fichiers sensibles** :
   - Archive et chiffre les clés dans un fichier `.tar.gz.gpg` protégé par un mot de passe.
4. **Suppression sécurisée de la clé privée** :
   - Après la création de l'archive, la clé privée en clair est automatiquement supprimée.

---


## 📂 Préparation de l'environnement

### 🖥️ Prérequis pour Windows et Linux

1. **Git** : Pour cloner le dépôt contenant le script.
2. **GPG** : Pour le chiffrement des fichiers (installé par défaut sur la plupart des distributions Linux).
3. **Un shell compatible Bash** :
   - **Windows** : Utilise [Git Bash](https://git-scm.com/downloads/win).
   - **Linux** : Le shell Bash est installé par défaut.


## 📚 Structure du dépôt

Voici un aperçu de la structure des fichiers dans le dépôt Git après clonage :

```bash
Client_VPN_WireGuard
├── setup_vpn_wireguard.sh      # Script principal
├── vpn_config.sh               # Fichier de configuration des variables
├── wilders.csv                 # Liste des wilders
├── template-procedure.txt      # Modèle de procédure pour les wilders
└── README.md                   # Cette documentation du script
```


---

## 💻 Comment utiliser le script ?

Pour les étapes détaillées, consulte la section [Utilisation du script](#-utilisation-du-script).

---

## 🔧 Configuration du script

### ✏️ Configuration des variables

✨ Avant d'utiliser le script, il est important de configurer les variables nécessaires dans le fichier `vpn_config.sh`. 

Ce fichier contient toutes les variables nécessaires pour personnaliser le déploiement.

Le script à été pensé pour fonctionner avec un sous-réseau de VPN utilisant un **masque CIDR `/16`** . 

Dans mon cas, j'utilise le sous-réseau `172.31`, et ceci pour plusieurs raisons :
* Le sous-réseau de VPN ne doit être utilisé par aucun coté du tunnel, que ce soit chez les élèves, ou dans le LAN pfSense. Il y a peu de chance que les élèves utilisent un sous-réseau `172.31.x.x/16` chez eux.
* Je me sert du 3 eme octet pour identifier le crew, et du 4 eme octet pour identifier l'élève. Ainsi, chaque crew dispose des mêmes 3 premiers octets.


>Cette partie necessiterai sûrement une amélioration, afin de correspondre à plusieurs scénarios d'utilisation du tunnel VPN.


### 🌟 Variables à modifier :

- **`SERVER_PUBLIC_KEY`** : Clé publique du serveur WireGuard. A RECUPERER SUR LE SERVEUR WIREGUARD
- **`SERVER_TUNNEL_IP`** : Adresse IP du tunnel (ex. "172.31.255.254/32"). (il faut déclarer l'interface, et donc utiliser un masque /32) A RECUPERER SUR LE SERVEUR WIREGUARD
- **`VPN_SUBNET`** : Sous-réseau accessible via le VPN (ex. "192.168.50.0/24"). En gros, le sous-réseau LAN de ton firewall pfSense
- **`VPN_ENDPOINT_IP`** : Adresse IPv4 publique du serveur VPN (ex. "203.0.113.10"). C'est l'adressse de ton serveur Proxmox VE
- **`TUNNEL_MASK`** : Masque de réseau du tunnel WireGuard (ex. "/16"). 
- **`DNS`** : Adresse de l'interface LAN de pfsense, pour que les clients VPN l'utilisent comme premier serveur DNS (ex. "192.168.50.254").
- **`BASE_IP`** : Base pour les adresses des clients VPN. En fonction de la valeur de la variable `$TUNNEL_MASK` que tu as renseigné (ex. "172.31"). Cette variable va servir à générer des adresses IP pour les clients VPN, et maintiendra à jour les adresses déjà utilisées dans un fichier généré automatiquement par le script (fichier `ip.txt`).


✨ Voici un exemple de fichier `vpn_config.sh` :
```bash
#!/bin/bash

# Répertoire de travail
WORKDIR=$(pwd)

# Fichiers
CSV_FILE="$WORKDIR/wilders.csv" # Fichier contenant les informations des Wilders
IP_FILE="$WORKDIR/ip.txt" # Fichier pour suivre les adresses IP attribuées
TEMPLATE_FILE="$WORKDIR/template-procedure.md" # Modèle de procédure pour les élèves
OUTPUT_DIR="$WORKDIR/output" # Répertoire de sortie pour les fichiers générés

# Informations WireGuard
SERVER_PUBLIC_KEY="KyD5aC8qZaZqNJ53wtg4s2vJOyEwo5HrGAGUjE7+qQQ="
SERVER_TUNNEL_IP="172.31.255.254/32"
VPN_SUBNET="192.168.50.0/24"
VPN_ENDPOINT_IP="144.76.100.132"
TUNNEL_MASK="/16"
DNS="192.168.50.254"

# Variables réseau
BASE_IP="172.31" # Base pour les adresses VPN (172.31.x.y)
``` 

### ✏️ Déclaration des élèves dans le fichier `wilders.csv`

Le fichier `wilders.csv`  contient les informations sur les élèves. Il est utilisé pour générer les configurations VPN pour chacun d'eux.

```csv
crew,prenom,nom 
1,Jean,jacques
1,Jean,Marc
2,Jean,Pierre
```

- **`crew`**: Identifiant du groupe. Les valeurs doivent êtres comprises entre `0` et `254` (`255` étant utilisé pour l'interface de tunnel du serveur), car cette valeur va déterminer le 3 eme octet des adresses IPv4 pour les clients VPN. J'ai pensé le script pour utiliser par exemple la valeur `0` pour les formateurs, la valeur `1` pour ton premier groupe de wilder, la valeur `2` pour ton second groupe etc...
- **`prenom`** et **`nom`**: Prénom et nom de l'élève.

> N'oublie pas de te rajouter ! 



---

## 📄 Utilisation du script

### 🛠️ Étape 1 : Prépare l’environnement

1. ✨ **Clone le dépôt dans un répertoire de travail :**
```bash
git clone git@github.com:JulienWild/Client_VPN_WireGuard.git
cd Client_VPN_WireGuard
```

2. ✨ **Ouvre le fichier `vpn_config.sh` et déclare les variables pour qu'elles correspondent à ta configuration :**
```bash
 nano vpn_config.sh
```

3. ✨ **Rends les scripts exécutables :**
```bash
chmod +x setup_vpn_wireguard.sh
chmod +x vpn_config.sh
```
4. ✨ **Ajoute les utilisateurs dans le fichier `wilders.csv` :**
```csv
crew,prenom,nom
0,Julien,Gregoire 
1,Jean,jacques
1,Jean,Marc
2,Jean,Pierre
```

---

### 🛠️ Étape 2 : Lance le script

```bash
sudo ./setup_vpn_wireguard.sh
```
> Le script doit être joué avec les droits **root**.



Arborescence repertoire après exécution du script :

```bash
.
├── ip.txt
├── output
│   ├── Jean_jacques
│   │   ├── Jean_jacques_keys.tar.gz.gpg
│   │   ├── Jean_jacques_WIREGUARD-public.key
│   │   ├── password.txt
│   │   └── procedure.md
│   ├── Jean_Marc
│   │   ├── Jean_Marc_keys.tar.gz.gpg
│   │   ├── Jean_Marc_WIREGUARD-public.key
│   │   ├── password.txt
│   │   └── procedure.md
│   ├── Jean_Pierre
│   │   ├── Jean_Pierre_keys.tar.gz.gpg
│   │   ├── Jean_Pierre_WIREGUARD-public.key
│   │   ├── password.txt
│   │   └── procedure.md
│   └── Julien_Gregoire 
│       ├── Julien_Gregoire _keys.tar.gz.gpg
│       ├── Julien_Gregoire _WIREGUARD-public.key
│       ├── password.txt
│       └── procedure.md
├── README.md
├── setup_vpn_wireguard.sh
├── template-procedure.md
├── vpn_config.sh
└── wilders.csv

```

---

## 🎯 Résultat attendu
Une fois le script exécuté, les éléments suivants seront générés pour chaque utilisateur dans le répertoire output/<Nom_Utilisateur>:

* **Clé publique et privée** (clé privée supprimée après archivage et chiffrement).
* **Procédure personnalisée** : Fichier Markdown contenant les étapes de configuration du VPN pour chaque wilder.
* **Archive chiffrée** : Contient la clé publique et la clé privée.

> La procédure générée indique à chaque wilder comment extraire l'archive chiffrée, et comment configuer son client VPN WireGuard.

***Le script crée aussi un fichier `ip.txt` pour suivre les adresses IPv4 de tunnel des clients déjà utilisées, afin de ne pas faire de doublons. (Crée le fichier seulement la première fois qu'on exécute le script ...)***

Exemple de fichier `ip.txt` généré :
```
0 Julien_Gregoire  172.31.0.1 
1 Jean_jacques 172.31.1.1 
1 Jean_Marc 172.31.1.2 
2 Jean_Pierre 172.31.2.1
```


---

# 📤 Transmission des fichiers aux élèves
Une fois les fichiers générés par le script, il est essentiel de les transmettre aux élèves en respectant les bonnes pratiques de sécurité . 

Pour éviter toute compromission, l'archive chiffrée, la procédure et le fichier contenant le mot de passe **ne doivent pas être envoyés via le même canal de communication**.

📦 **Étape 1 : Envoyer l'archive chiffrée ( .tar.gz.gpg)**
1. Envoie l'archive contenant les clés WireGuard (.tar.gz.gpg) à l'élève via un canal sécurisé comme Slack.

2. Informe l'élève que l'archive est protégée par un mot de passe et que les instructions pour l'extraction suivront via un autre canal.


📜 **Étape 2 : Transmettre la procédure et le mot de passe**

Envoie la procédure personnalisée (procedure.md) et le mot de passe (password.txt) via un canal différent de celui utilisé pour transmettre l'archive (par exemple, par email si l'archive a été envoyée via Slack).

💡 Bonnes pratiques :
* 🛡️ Séparation des canaux : Le mot de passe ne doit jamais transiter par le même canal que l'archive.
* 🔒 Confidentialité des fichiers : Assure-toi que seuls les élèves concernés ont accès aux fichiers.
* 🔄 Validation de réception : Demande aux élèves de confirmer la réception de l'archive, de la procédure, et du mot de passe.


---
## 🚦 Procédures supplémentaires

# ⛵ Ajout d'un nouvel équipage ?
Si tu accueilles un nouveau crew dans quelques semaines ou mois, il te suffit de mettre à jour le fichier `wilders.csv` en y ajoutant les informations des nouveaux wilders, puis de relancer le script.

⚙️ Le script est conçu pour éviter les doublons : si un wilder est déjà configuré, ses fichiers ne seront pas recréés ni écrasés.

---

## 🆕 Réinitialiser complètement le script
Si tu souhaites repartir de zéro pour une raison particulière (par exemple, pour tester ou corriger un problème), voici les étapes à suivre :

1. Supprime le fichier contenant les adresses IP déjà attribuées :
```bash
sudo rm ip.txt
```

2. Supprime également le répertoire contenant les fichiers générés :
```bash
sudo rm -rf output
```

>⚠️ Attention : Réinitialiser efface tout l'historique.
>Les adresses IPv4 déjà attribuées ne seront plus suivies.
>Les clés générées pour les tunnels VPN seront définitivement perdues.
>Cette procédure est à utiliser uniquement dans un contexte de test ou de développement. En production , il est fortement déconseillé de réaliser cette réinitialisation.

---

## ❌ Supprimer un seul élève
Si tu as besoin de supprimer un élève spécifique tout en conservant les données des autres, voici comment procéder :

1. Supprime son nom de fichier `wilders.csv`

2. Supprime la ligne associée à cet élève dans le fichier `ip.txt`

3. Supprime son dossier dans le répertoire `output` :
```bash
sudo rm -rf output/<Nom_Utilisateur>
```

---

# 📬  En cas de problème ?

- **Besoin d'aide ?** : Contacte l'administrateur ou ouvre un ticket sur le dépôt Git.



