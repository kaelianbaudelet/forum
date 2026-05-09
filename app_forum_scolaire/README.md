# Forum Scolaire - Application Mobile

Cette application mobile développée avec Flutter permet aux étudiants d'interagir avec le **Forum Scolaire**. Elle offre une interface fluide et intuitive pour consulter les forums, lire des messages et participer aux discussions.

## 📱 Fonctionnalités

- **Authentification** : Connexion et inscription sécurisées.
- **Gestion de Profil** : Visualisation des informations utilisateur.
- **Forums** : Navigation à travers les différentes catégories de forums.
- **Messages** : Lecture et rédaction de nouveaux messages.
- **Utilisateurs** : Liste des membres de la communauté.

## 🚀 Technologies Utilisées

- **Framework** : [Flutter](https://flutter.dev/)
- **Gestion d'état** : [Provider](https://pub.dev/packages/provider)
- **Stockage Sécurisé** : [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) (pour les tokens JWT)
- **Variables d'environnement** : [Flutter Dotenv](https://pub.dev/packages/flutter_dotenv)
- **Réseau** : [HTTP](https://pub.dev/packages/http)

## 📋 Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version compatible avec le SDK Dart ^3.11.1)
- Un simulateur iOS, un émulateur Android ou un appareil physique.
- L'API du backend en cours d'exécution.

## ⚙️ Installation

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd app_forum_scolaire
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer l'environnement**
   Créez un fichier `.env.local` dans le dossier `assets/` et configurez l'URL de votre API :
   ```env
   API_BASE_URL=http://localhost:8000/api
   ```
   *(Note : Utilisez `10.0.2.2` au lieu de `localhost` si vous testez sur un émulateur Android)*.

4. **Lancer l'application**
   ```bash
   flutter run
   ```

## 📂 Structure du Projet

- `lib/api/` : Services de communication avec l'API Symfony.
- `lib/models/` : Modèles de données (User, Forum, Message).
- `lib/providers/` : Logique métier et gestion d'état (Auth).
- `lib/screens/` : Interfaces utilisateur (Écrans).
- `lib/utils/` : Utilitaires (Stockage sécurisé, etc.).
