#!/bin/bash
# ClickHouse Migration Script
# startup/init.sh

# Directory containing migration scripts
MIGRATIONS_DIR="/etc/clickhouse-server/migrations"

# Check if the migrations table exists, and if not, create it
if ! clickhouse-client --query "EXISTS TABLE gova11y.migrations"; then
    clickhouse-client --query "
        CREATE TABLE gova11y.migrations
        (
            migration_name String,
            applied_at DateTime DEFAULT now()
        )
        ENGINE = MergeTree
        ORDER BY migration_name
        SETTINGS index_granularity = 8192;"
fi

# Loop through migration scripts in order
for migration in $(ls $MIGRATIONS_DIR | sort); do
    # Check if the migration has been applied already
    if ! clickhouse-client --query "SELECT 1 FROM gova11y.migrations WHERE migration_name='$migration'"; then
        clickhouse-client < "$MIGRATIONS_DIR/$migration"
        if [ $? -ne 0 ]; then
            # If there's an error running the script, exit
            echo "Error applying migration $migration"
            exit 1
        else
            echo "Applied migration $migration"
            # Record the migration in the migrations table
            clickhouse-client --query "INSERT INTO gova11y.migrations (migration_name) VALUES ('$migration')"
        fi
    else
        echo "Migration $migration already applied, skipping"
    fi
done


