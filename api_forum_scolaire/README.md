# Forum Scolaire - API

Cette API REST est le moteur du projet **Forum Scolaire**. Elle est construite avec Symfony et API Platform pour fournir une interface de données robuste et sécurisée à l'application mobile.

## 🚀 Technologies Utilisées

- **Framework** : [Symfony 6.4](https://symfony.com/)
- **API** : [API Platform 4.2](https://api-platform.com/)
- **Base de données** : MariaDB 12
- **Authentification** : JWT (JSON Web Token) via LexikJWTAuthenticationBundle
- **Docker** : Orchestration des services (Serveur web, Base de données, DbGate)
- **Outils de développement** : MakerBundle, Doctrine Fixtures

## 📋 Prérequis

- [Docker](https://www.docker.com/) et [Docker Compose](https://docs.docker.com/compose/)
- [PHP 8.1+](https://www.php.net/) (optionnel si utilisation complète de Docker)
- [Composer](https://getcomposer.org/)

## ⚙️ Installation

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd api_forum_scolaire
   ```

2. **Lancer les services Docker**
   ```bash
   docker-compose up -d
   ```

3. **Installer les dépendances PHP** (si nécessaire localement)
   ```bash
   composer install
   ```

4. **Configurer la sécurité JWT**
   Générez les clés nécessaires pour l'authentification :
   ```bash
   php bin/console lexik:jwt:generate-keypair
   ```

5. **Initialiser la base de données**
   Exécutez les migrations et chargez les données de test :
   ```bash
   php bin/console doctrine:migrations:migrate --no-interaction
   php bin/console doctrine:fixtures:load --no-interaction
   ```

## 🛠 Services Inclus

- **Serveur Web** : Accessible sur [http://localhost:8000](http://localhost:8000)
- **API Platform (Swagger)** : Documentation interactive sur [http://localhost:8000/api](http://localhost:8000/api)
- **DbGate** : Interface de gestion de base de données sur [http://localhost:3000](http://localhost:3000)

## 🔐 Authentification

L'API utilise des tokens JWT pour sécuriser les ressources. 
- **Endpoint de login** : `POST /api/authentication_token`
- **Payload** : `{"email": "...", "password": "..."}`
- **Usage** : Ajouter le token dans le header `Authorization: Bearer <votre_token>` pour les requêtes protégées.

## 📂 Structure des Entités

- **User** : Gestion des utilisateurs (Rôles, Email, Password).
- **Forum** : Catégories ou sujets principaux du forum.
- **Message** : Contributions des utilisateurs au sein des forums.
