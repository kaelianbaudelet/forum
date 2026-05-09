#!/bin/sh
set -e

# Attendre que la base de données soit prête (optionnel car depends_on healthcheck gère déjà ça normalement, mais c'est une bonne sécurité)
echo "Running migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration

echo "Loading fixtures..."
php bin/console doctrine:fixtures:load --no-interaction

echo "Starting main process..."
exec "$@"
