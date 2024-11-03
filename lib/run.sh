#!/bin/bash

# Assurez-vous d'être dans le bon répertoire
cd lib/AI/ || exit

# Vérifier si pip est installé
if ! command -v pip &> /dev/null; then
    echo "pip n'est pas installé. Installation de pip..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
fi

# Créer un environnement virtuel si nécessaire
if [ ! -d "venv" ]; then
    echo "Création de l'environnement virtuel..."
    python -m venv venv
fi

# Activer l'environnement virtuel
source venv/bin/activate  # Sur Windows, utilisez venv\Scripts\activate

# Installer les dépendances Python
echo "Installation des dépendances Python..."
pip install -r requirements.txt

# Lancer le script Python
echo "Lancement de app.py..."
python app.py &  # Exécute en arrière-plan

# Retourner au répertoire du projet Flutter
cd ..|| exit

