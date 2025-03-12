#!/bin/bash

# Exit immediately if any command fails
set -e

echo "🔧 Setting up PostgreSQL for testing..."

# Read input from arguments or prompt the user
POSTGRES_USER=${1:-}
POSTGRES_PASSWORD=${2:-}

if [[ -z "$POSTGRES_USER" ]]; then
  read -p "Enter PostgreSQL username: " POSTGRES_USER
fi

if [[ -z "$POSTGRES_PASSWORD" ]]; then
  read -s -p "Enter PostgreSQL password: " POSTGRES_PASSWORD
  echo ""
fi

# Check if the user exists, create if not
echo "👤 Checking if user '$POSTGRES_USER' exists..."
USER_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRES_USER'")

if [[ "$USER_EXISTS" != "1" ]]; then
  echo "👤 Creating user '$POSTGRES_USER'..."
  sudo -u postgres psql -c "CREATE USER $POSTGRES_USER WITH SUPERUSER;"
  echo "🔑 Setting password for user '$POSTGRES_USER'..."
  sudo -u postgres psql -c "ALTER USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';"
else
  echo "✅ User '$POSTGRES_USER' already exists."
fi

echo "✅ PostgreSQL setup complete!"
