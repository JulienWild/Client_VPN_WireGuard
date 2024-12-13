
[![forthebadge](https://forthebadge.com/images/badges/made-with-markdown.svg)](https://forthebadge.com) 

---


<h1 align="center">
🛠️  Script de Configuration des clients VPN WireGuard - Guide pour les Formateurs
</h1>



## Table of contents

- [🚀 Bienvenue !](## 🚀 Bienvenue !)
- [📂 Préparation de l'environnement](## 📂 Préparation de l'environnement)
- [📂 Structure du dépôt](## 📂 Structure du dépôt)
---

## 🚀 Bienvenue !

Ce script est conçu pour t'aider à déployer rapidement et efficacement des configurations VPN WireGuard pour tes élèves. 


```spacer small
```

---


## 📂 Préparation de l'environnement

### 🖥️ Windows

✨ 1. **Installe Git et Git Bash** :  Télécharge et installe [Git pour Windows](https://git-scm.com/download/win) . Lors de l'installation, assure-toi d'inclure Git Bash.

✨ 2. **Crée le répertoire de travail** :
1. Ouvre **Git Bash**.
2. Crée un répertoire `scripts` à l'emplacement de ton choix, par exemple ton dossier utilisateur :
```bash
mkdir ~/scripts
```

```spacer small
```

✨ 3. **Clone le dépôt Git** :  
Depuis ton terminal **Git Bash**, place toi dans le dossier `scripts` et clone le repo GitHub qui contient le projet :
```bash
cd ~/scripts
git clone git@github.com:JulienWild/Client_VPN_WireGuard.git
```

```spacer small
```

✨ 4. **Rendre les scripts exécutables** :  
Navigue dans le répertoire cloné et rends les scripts exécutables : 
```bash
cd ~/scripts
chmod +x setup_vpn_wireguard.sh 
chmod +x vpn_config.sh
```

```spacer small
```


### 🐧 Linux Debian

✨ 1. **Crée le répertoire de travail** à l'emplacement de ton choix :  

```bash
mkdir ~/scripts
```

```spacer small
```

✨ 2. **Clone le script dans le répertoire `scripts`:**
```bash
git clone git@github.com:JulienWild/Client_VPN_WireGuard.git ~/scripts
```

```spacer small
```

✨ 3. **Navigue dans le répertoire cloné et rends les scripts exécutables :**
```bash
cd ~/scripts
chmod +x setup_vpn_wireguard.sh 
chmod +x vpn_config.sh
```

```spacer small
```
---


## 📂 Structure du dépôt

Voici l'arborescence du dépôt après clonage :

```bash
~/scripts/
├── setup_vpn_wireguard.sh      # Script principal
├── vpn_config.sh               # Fichier de configuration des variables
├── wilders.csv                 # Liste des élèves
├── template-procedure.txt      # Modèle de procédure pour les élèves

``` 
```spacer small
```
---


## 🛠️  Configuration des variables

Le script utilise un fichier de configuration `vpn_config.sh`. 

Ce fichier contient toutes les variables nécessaires pour personnaliser le déploiement.

Le script à été pensé pour fonctionner avec un sous-réseau de VPN utilisant un masque CIDR `/16` . 

Dans mon cas, j'utilise le sous-réseau `172.31`, et ceci pour plusieurs raisons :
* Le sous-réseau de VPN ne doit être utilisé par aucun coté du tunnel, que ce soit chez les élèves, ou dans le LAN pfSense. Il y a peu de chance que les élèves utilisent un sous-réseau `172.31.x.x/16` chez eux.
* Je me sert du 3 eme octet pour identifier le crew, et du 4 eme octet pour identifier l'élève. Ainsi, chaque crew dispose des mêmes 3 premiers octets.

```alert info
Cette partie necessiterai sûrement une amélioration, afin de correspondre à plusieurs scénarios d'utilisation du tunnel VPN.
```

### 🌟 Variables à modifier :

- **`SERVER_PUBLIC_KEY`** : Clé publique du serveur WireGuard. A RECUPERER SUR LE SERVEUR WIREGUARD
- **`SERVER_TUNNEL_IP`** : Adresse IP du tunnel (ex. "172.31.255.254/32"). A RECUPERER SUR LE SERVEUR WIREGUARD
- **`VPN_SUBNET`** : Sous-réseau accessible via le VPN (ex. "192.168.50.0/24"). En gros, le sous-réseau LAN de ton firewall pfSense
- **`VPN_ENDPOINT_IP`** : Adresse IPv4 publique du serveur VPN (ex. "203.0.113.10"). C'est l'adressse de ton serveur Proxmox VE
- **`TUNNEL_MASK`** : Masque de réseau du tunnel WireGuard (ex. "/16"). 
- **`DNS`** : Adresse de l'interface LAN de pfsense, pour que les clients VPN l'utilisent comme premier serveur DNS (ex. "192.168.50.254").
- **`BASE_IP`** : Base pour les adresses des clients VPN. En fonction de la valeur de la variable `$TUNNEL_MASK` que tu as renseigné (ex. "172.31"). Cette variable va servir à générer des adresses IP pour les clients VPN, et maintiendra à jour les adresses déjà utilisées dans un fichié généré automatiquement par le script (fichier `ip.txt`).

### ✏️  Modifie les variables :

✨ 1. Ouvre le fichier `vpn_config.sh` et déclare les variables pour qu'elles correspondent à ta configuration.

Tu peux retrouver la valeur de certaines variables directement sur ton serveur VPN WireGuard. Te rapelles-tu, dans la section précédente **3.1. Serveur VPN WireGuard - coté pfSense**, tu avais noté les valeurs des variables :
* `Public Key` : correspond à la variable **`SERVER_PUBLIC_KEY`**
* `Interface Addresses` : correspond à la variable **`SERVER_TUNNEL_IP`**
* `Mask` : correspond à la variable **`TUNNEL_MASK`**

```spacer small
```
---


## 📄 Configure le fichier`wilders.csv`

Le fichier `wilders.csv`  contient les informations sur les élèves. Il est utilisé pour générer les configurations VPN.

### Format du fichier : csv

```csv
crew,prenom,nom 
1,Jean,jacques
1,Jean,Marc
2,Jean,Pierre
```
```spacer small
```

- **`crew`**: Identifiant du groupe. Les valeurs doivent êtres comprises entre `0` et `254` (`255` étant utilisé pour l'interface de tunnel du serveur), car cette valeur va déterminer le 3 eme octet des adresses IPv4 pour les clients VPN. J'ai pensé le script pour utiliser par exemple la valeur `0` pour les formateurs, la valeur `1` pour ton premier groupe de wilder, la valeur `2` pour ton second groupe etc...
- **`prenom`** et **`nom`**: Prénom et nom de l'élève.

### 🖋️  Ajout des élèves :

✨ 1. Ouvre le fichier `wilders.csv` et ajoute une nouvelle ligne pour chaque élève.

Exemple :


```
crew,prenom,nom 
O,Julien,Gregoire
```

```alert info
N'oublie pas de te rajouter ! 
```

---


---

## 🔧  Exécute le script

✨ 1. **Exécute le script principal** :

```bash
./setup_vpn_wireguard.sh
```

✨ 2. Le script :

- Crée un fichier `ip.txt` pour suivre les adresses IPv4 de tunnel des clients déjà utilisées, afin de ne pas faire de doublons. (Crée le fichier seulement la première fois qu'on exécute le script ...)
- Utilise le fichier `wilders.csv` pour créer les fichiers de configuration pour chaque élève.

✨ 3. **Vérifie les résultats** :  
Les fichiers générés sont stockés dans le répertoire `output`. Chaque élève aura un sous-dossier avec ses clés et sa procédure.


---
## 👤 Un autre crew ?

Si dans quelques temps, tu forme un nouveau crew, il suffit alors de rajouter les wilders au fichier `wilders.csv` .

> Rejouer le script ne crée pas de doublons.

---
## 🆕 Recommencer à partir de zéro

Si tu souhaites repartir à zéro pour une raison ou pour une autre, il suffit de supprimer le fichier  `ip.txt`  et le répertoire `output`, ils seront recréés à la prochaine exécution du script :

```bash
sudo rm ip.txt
sudo rm -rf output
``` 

```alert warning
Attention toutefois si tu as déjà créé des cliçents VPN, car tu n'auras plus aucun suivi des adresses IPv4 déjà attribuées, et tu ne disposeras plus des clés pour le tunnel.
Recommencer à pertir de zéro suggère que tu est dans une phase de test. 
Une fois en production, il est fortement déconseillé de réaliser cette procédure.
```

Dans le scénario où tu souhaites seulement supprimer un élève, tu n'as qu'a supprimer son nom de la liste dans le fichier `wilders.csv` , supprimer la ligne qui le concerne dans le fichier `ip.txt`, et supprimer aussi son dossier nominatif dans le répertoire `output` .


---

## 📬  En cas de problème ?

- **Clé publique incorrecte** : Assure-toi d'avoir la bonne clé publique dans `vpn_config.sh`.
- **Besoin d'aide ?** : Contacte l'administrateur ou ouvre un ticket sur le dépôt Git.

---

## 💡 Astuce pour les mises à jour

Pour récupérer les dernières mises à jour du script :

```bash
cd ~/script/Client_VPN_WireGuard git pull
```



