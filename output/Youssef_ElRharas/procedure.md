================================================================================
   🛡️  Procédure d'installation et de configuration du client VPN Wireguard 🛡️
================================================================================

Bonjour Youssef,

Voici les étapes détaillées pour installer et configurer ton client VPN WireGuard. Grâce à ce tunnel sécurisé, tu pourras accéder au serveur PnetLab nécessaire à ton projet. 

Suis bien chaque étape, et en cas de problème, ton formateur est là pour t’aider !

--------------------------------------------------------------------------------
# 📃 Informations sur le VPN
--------------------------------------------------------------------------------
Voici les paramètres spécifiques à ta configuration :
- **Clé publique du serveur** : KyD5aC8qZaZqNJ53wtg4s2vJOyEwo5HrGAGUjE7+qQQ=
- **Adresse IP de l'interface tunnel (wg0 sur le serveur)** : 172.31.255.254/32
- **Sous-réseau accessible via le VPN** : 192.168.50.0/24
- **Endpoint (adresse publique du serveur)** : 144.76.100.132

--------------------------------------------------------------------------------
# 🛠️ Étapes d'installation et de configuration
--------------------------------------------------------------------------------

## 1️⃣  Installation de WireGuard
### Sous Windows
1. Télécharge l'application WireGuard depuis [le site officiel](https://www.wireguard.com/install/).
2. Suis les étapes de l'assistant pour installer l'application.
3. Lance l'application WireGuard.

### Sous Linux (Debian)
1. Ouvre un terminal.
2. Installe WireGuard avec la commande :

```bash
sudo apt update && sudo apt install -y wireguard
```

## 2️⃣  Décompression de l'archive chiffrée

Ton formateur-trice t'a envoyé un fichier qui porte l'extension `.tar.gz.gpg`.
Ce fichier contient ta **clé privée** et ta **clé publique**.

Avant de pouvoir y avoir accès, tu dois le déchiffrer avec le mot de passe contenu dans le fichier `password.txt` que ton formateur te transmettra, puis décompresser l'archive.

1. ✨ Ouvre un terminal à l’emplacement de ton fichier chiffré.

2. ✨ Déchiffre l'archive en utilisant le mot de passe communiqué par ton formateur :

```bash
sudo gpg --batch --yes --decrypt --passphrase "mot_de_passe" -o keys.tar.gz {{WILDER_NAME}}_keys.tar.gz.gpg
```

> Remplace "`mot_de_passe`"  par le mot de passe contenu dans le fichier `password.txt` et `{{WILDER_NAME}}_keys.tar.gz.gpg` par le nom de ton fichier à déchiffrer.

> Tu peux aussi utiliser un autre nom de sortie, dans l'exemple le fichier résultant se nommera `keys.tar.gz` (mais garde l'extension`.tar.gz` quand même).

3. ✨ Décompresse l'archive :

```bash
sudo tar -xvzf keys.tar.gz
```

4. ✨ Résultats :

```bash
{{WILDER_NAME}}_WIREGUARD.key
{{WILDER_NAME}}_WIREGUARD-public.key
```

> Tu disposes désormais de ta clé privée et clé publique. Ces informations te permettent de configurer ton client VPN WireGuard.


## 3️⃣  Configuration de l'interface WireGuard

### 1. Configure l'interface WireGuard avec les paramètres suivants :
```bash
[Interface]
PrivateKey = contenu de {{WILDER_NAME}}_WIREGUARD.key
Address = 172.31.2.2/16
SaveConfig = true
ListenPort = 51820
DNS = 192.168.50.254, 9.9.9.9, 8.8.8.8

[Peer]
PublicKey = KyD5aC8qZaZqNJ53wtg4s2vJOyEwo5HrGAGUjE7+qQQ=
AllowedIPs = 192.168.50.0/24, 172.31.255.254/32
Endpoint = 144.76.100.132:51820
```

* Paramètres pour ce client :
   * `PrivateKey` = La clé privée générée pour toi. 
   * `Address` = Ton adresse IP dans le tunnel VPN.
   * `ListenPort` = Port statique d'écoute par défaut.
   * `DNS` = Le(s) serveur(s) DNS qui doivent être utilisés par le système lorsque le tunnel est activé.

* Paramètres pour l'extrémité du tunnel - Le serveur
   * `PublicKey` = Clé publique du serveur VPN.
   * `AllowedIPs` = Réseaux accessibles via le VPN.
   * `Endpoint` = L'adresse IP WAN du pare-feu et le port d'écoute du service WireGuard.


### 2. Active le tunnel et vérifie la connectivité.

#### Sous Windows :
Dans l'application WireGuard, sélectionne le tunnel que tu as configuré et clique sur `Activer`

```alert info
Lorsque tu modifies la configuration de ton tunnel, ou que tu rencontres des difficultés à activer le service, il faut désactiver l'interface préalablement.
``` 

#### Sous Linux (Debian) :
```bash
sudo wg-quick up wg0
```

Active le démarrage automatique de l'interface du tunnel :
```bash
sudo systemctl enable wg-quick@wg0
```

--------------------------------------------------------------------------------------
# 🔍 Vérifications
--------------------------------------------------------------------------------------

* **Sous Windows :**
Il est assez facile de vérifier, à l'aide de l'interface graphique sur Windows, si des datas circulent dans le tunnel.  
Dans la partie `Homologue`, on voit en direct le nombre de données échangées.


* **Sous Linux (Debian) :** 

On peut vérifier la configuration de l'interface `wg0` via la commande `wg show` :
```bash
sudo wg show wg0
interface: wg0
  public key: ...
  private key: (hidden)
  listening port: 51820

peer : ...
  endpoint: ...
  allowed ips: ...
```

```alert info
Si la section `peer` n'apparaît pas, c'est que le tunnel VPN n'est pas établi.
``` 

Observe les logs de ton interface `wg0` :
```bash
sudo journalctl -u wg-quick@wg0
```


````alert-warning
Lorsque tu modifies la configuration de ton tunnel, ou que tu rencontres des difficultés à lancer le service, il faut désactiver l'interface préalablement.
```bash
sudo wg-quick down wg0
```
Réalise les modifications puis relance l'interface :
```bash
sudo wg-quick up wg0
```
````

Effectue une requête ICMP sur l'interface de sortie du VPN :
```
ping 172.31.255.254
``` 

-------------------------------------------------------------------------------------------
# 📬 Support 
-------------------------------------------------------------------------------------------

Si tu rencontres des problèmes, n’hésite pas à contacter ton formateur-trice via Slack ou par email 😊

