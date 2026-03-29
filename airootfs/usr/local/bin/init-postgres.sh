#!/bin/bash
set -e

DATA_DIR="/var/lib/postgres/data"

# init db если нет
if [ ! -d "$DATA_DIR/base" ]; then
    echo "Initializing PostgreSQL..."
    sudo -u postgres initdb -D "$DATA_DIR"
fi

# копируем конфиги
cp /etc/postgresql/postgresql.conf "$DATA_DIR/postgresql.conf"
cp /etc/postgresql/pg_hba.conf "$DATA_DIR/pg_hba.conf"

# стартуем временно
sudo -u postgres pg_ctl -D "$DATA_DIR" -w start

# создаём пользователя и базу
sudo -u postgres psql <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'user') THEN
      CREATE ROLE user LOGIN PASSWORD 'password';
   END IF;
END
\$\$;

CREATE DATABASE "test-db"
    OWNER user
    ENCODING 'UTF8'
    LC_COLLATE 'en_US.UTF-8'
    LC_CTYPE 'en_US.UTF-8'
    TEMPLATE template1;

\connect "test-db"

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
EOF

# стоп
sudo -u postgres pg_ctl -D "$DATA_DIR" -m fast -w stop
