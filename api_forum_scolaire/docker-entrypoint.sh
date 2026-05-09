#!/bin/sh
set -e

# Wait for DB to be ready and apply migrations
echo "Running migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration

echo "Checking if database is empty..."
USER_COUNT=$(php bin/console dbal:run-sql 'SELECT COUNT(*) FROM user' 2>/dev/null | grep -Eo '[0-9]+' | tail -1 || echo "0")

if [ "$USER_COUNT" = "0" ] || [ -z "$USER_COUNT" ]; then
    echo "Database is empty. Loading fixtures..."
    php bin/console doctrine:fixtures:load --no-interaction
else
    echo "Database already contains data (found $USER_COUNT users). Skipping fixtures."
fi

echo "Starting main process..."
exec "$@"
