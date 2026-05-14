# Projet Forum Scolaire

Bienvenue dans le projet **Forum Scolaire**, une plateforme complète d'échange pour les étudiants, comprenant une API backend robuste et une application mobile moderne.

## 📂 Structure du Dépôt

Le projet est divisé en deux parties principales :

1.  **[api_forum_scolaire](./api_forum_scolaire)** : Le backend développé avec **Symfony 6.4** et **API Platform**. Il gère la logique métier, la base de données MariaDB et la sécurité via JWT.
2.  **[app_forum_scolaire](./app_forum_scolaire)** : L'application mobile développée avec **Flutter**. Elle offre une expérience utilisateur fluide pour interagir avec le forum.

## Démarrage Rapide

Pour mettre en place l'environnement complet :

### 1. Backend (API)
Rendez-vous dans le dossier de l'API et suivez les instructions du [README spécifique](./api_forum_scolaire/README.md).
En résumé :
```bash
cd api_forum_scolaire
docker-compose up -d
php bin/console lexik:jwt:generate-keypair
php bin/console doctrine:migrations:migrate
php bin/console doctrine:fixtures:load
```

### 2. Frontend (Mobile)
Rendez-vous dans le dossier de l'application mobile et suivez les instructions du [README spécifique](./app_forum_scolaire/README.md).
En résumé :
```bash
cd app_forum_scolaire
flutter pub get
# Configurez votre .env.local
flutter run
```

## 🛠 Architecture

Le projet suit une architecture découplée où l'application mobile communique avec l'API via des requêtes REST sécurisées par des tokens JWT.
