#!/bin/bash

# Exit if any command fails
set -e

# Read input from arguments or prompt the user
PG_USER=${1:-}
PG_PASSWORD=${2:-}

if [[ -z "$PG_USER" ]]; then
  read -p "Enter PostgreSQL username: " PG_USER
fi

if [[ -z "$PG_PASSWORD" ]]; then
  read -s -p "Enter PostgreSQL password: " PG_PASSWORD
  echo ""
fi

echo "Logging into PostgreSQL as postgres user..."

sudo -u postgres psql <<-EOF
-- Check if the user exists
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$PG_USER') THEN
      CREATE USER $PG_USER;
      RAISE NOTICE 'User $PG_USER created';
   ELSE
      RAISE NOTICE 'User $PG_USER already exists';
   END IF;
END
\$\$;

-- Grant superuser privileges
ALTER USER $PG_USER WITH SUPERUSER;

-- Set user password
ALTER USER $PG_USER WITH PASSWORD '$PG_PASSWORD';
EOF

echo "✅ PostgreSQL user '$PG_USER' setup complete."
