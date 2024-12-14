#!/bin/bash

# Charger les variables depuis le fichier de configuration
WORKDIR=$(pwd)
source "$WORKDIR/vpn_config.sh"

# === Fonctions ===

# Fonction pour générer une paire de clés
generate_keys() {
    local wilder_name="$1"
    local key_dir="$OUTPUT_DIR/$wilder_name"

    mkdir -p "$key_dir"
    wg genkey | sudo tee "$key_dir/${wilder_name}_WIREGUARD.key" > /dev/null
    cat "$key_dir/${wilder_name}_WIREGUARD.key" | wg pubkey | sudo tee "$key_dir/${wilder_name}_WIREGUARD-public.key" > /dev/null
}


# Fonction pour sécuriser une archive avec un mot de passe
create_secure_archive() {
    local wilder_name="$1"
    local key_dir="$OUTPUT_DIR/$wilder_name"
    local archive_file="$key_dir/${wilder_name}_keys.tar.gz.gpg"
    local private_key_file="${key_dir}/${wilder_name}_WIREGUARD.key"

    # Générer un mot de passe aléatoire
    local password=$(openssl rand -base64 12)
    echo "$password" > "$key_dir/password.txt"

    # Créer une archive TAR chiffrée contenant la clés publique/clé privée
    tar -czf - -C "$key_dir" "$(basename "${private_key_file}")" \
        "$(basename "${key_dir}/${wilder_name}_WIREGUARD-public.key")" | \
    gpg --batch --yes --symmetric --cipher-algo AES256 --passphrase "$password" -o "$archive_file"
    
    echo ""
    echo "✅ Archive chiffrée créée : $archive_file"

    # Supprimer le fichier en clair de clé privée
    rm -f "$private_key_file"
}


# Fonction pour générer une documentation personnalisée
generate_documentation() {
    local wilder_name="$1"
    local wilder_ip="$2"
    local public_key="$3"
    local hashed_key="$4"
    local doc_file="$OUTPUT_DIR/$wilder_name/procedure.md"

    # Copier le modèle dans le fichier de documentation
    cp "$TEMPLATE_FILE" "$doc_file"

    # Remplacements dans le fichier de documentation
    sed -i "s|{{NAME}}|$name|g" "$doc_file"
    sed -i "s|{{IP}}|$wilder_ip|g" "$doc_file"
    sed -i "s|{{PUBLIC_KEY}}|$public_key|g" "$doc_file"
    sed -i "s|{{HASHED_KEY}}|$hashed_key|g" "$doc_file"
    sed -i "s|{{VPN_SUBNET}}|$VPN_SUBNET|g" "$doc_file"
    sed -i "s|{{VPN_ENDPOINT_IP}}|$VPN_ENDPOINT_IP|g" "$doc_file"
    sed -i "s|{{SERVER_PUBLIC_KEY}}|$SERVER_PUBLIC_KEY|g" "$doc_file"
    sed -i "s|{{SERVER_TUNNEL_IP}}|$SERVER_TUNNEL_IP|g" "$doc_file"
    sed -i "s|{{TUNNEL_MASK}}|$TUNNEL_MASK|g" "$doc_file"
    sed -i "s|{{DNS}}|$DNS|g" "$doc_file"
}

# Fonction principale
setup_vpn_for_wilder() {
    local crew="$1"
    local prenom="$2"
    local nom="$3"
    local wilder_name="${prenom}_${nom}"
    local name="${prenom}"

    # Vérifier si les fichiers existent déjà
    if [[ -d "$key_dir" && -f "$key_dir/${wilder_name}_WIREGUARD.key" && -f "$key_dir/procedure.txt" ]]; then
        echo ""
        echo "🔄 Les fichiers pour $wilder_name existent déjà. Passage au suivant..."
        echo ""
        return
    fi

    # Obtenir la prochaine IP disponible pour ce crew
    local wilder_ip="${BASE_IP}.${crew}.$(awk -v crew_id="$crew" 'BEGIN {count=1} $1 ~ crew_id {count++} END {print count}' "$IP_FILE")"

    # Générer les clés
    generate_keys "$wilder_name"

    # Ajouter l'IP et le Wilder au fichier IP
    echo "$crew $wilder_name $wilder_ip $public_key" >> "$IP_FILE"

    # Créer une archive sécurisée
    create_secure_archive "$wilder_name"

    # Générer la documentation
    generate_documentation "$wilder_name" "$wilder_ip" "$public_key"

}

# === Main ===

# Vérifier les permissions
if [[ $EUID -ne 0 ]]; then
    echo ""
    echo "❌ Ce script doit être exécuté avec les privilèges root."
    echo ""
    exit 1
fi

# Vérifier les fichiers nécessaires
if [[ ! -f "$CSV_FILE" || ! -f "$TEMPLATE_FILE" ]]; then
    echo ""
    echo "❌ Fichiers nécessaires non trouvés : $CSV_FILE ou $TEMPLATE_FILE."
    echo ""
    exit 1
fi

# Vérifier si le fichier ip.txt existe, sinon le créer
if [[ ! -f "$IP_FILE" ]]; then
    echo ""
    echo "⚠️  Le fichier $IP_FILE est introuvable. Création d’un nouveau fichier vide..."
    echo ""
    touch "$IP_FILE"
    echo "✅ Fichier $IP_FILE créé avec succès."
    echo ""
fi

# Créer le répertoire de sortie
mkdir -p "$OUTPUT_DIR"
echo ""
echo "✅ Repertoire $OUTPUT_DIR créé avec succès."

# Lire le fichier CSV et traiter chaque Wilder
while IFS=',' read -r crew prenom nom; do
    if [[ "$crew" != "crew" ]]; then # Ignore la ligne d'en-tête
        setup_vpn_for_wilder "$crew" "$prenom" "$nom"
    fi
done < "$CSV_FILE"

echo ""
echo "✅ Configuration VPN Wireguard terminée pour tous les Wilders de la liste."
echo ""