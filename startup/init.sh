#!/bin/bash
# ClickHouse Migration Script
# startup/init.sh

MIGRATIONS_DIR="/etc/clickhouse-server/migrations"

# Check if the gova11y database exists, and if not, create it
db_exists=$(clickhouse-client --query "SELECT COUNT() FROM system.databases WHERE name='gova11y'")

if [[ "$db_exists" == "0" ]]; then
    clickhouse-client --query "CREATE DATABASE gova11y;"
    if [ $? -ne 0 ]; then
        echo "Error creating gova11y database."
        exit 1
    fi
fi

# Check if the migrations table exists, and if not, create it
table_exists=$(clickhouse-client --query "SELECT COUNT() FROM system.tables WHERE database='gova11y' AND name='migrations'")

if [[ "$table_exists" == "0" ]]; then
    clickhouse-client --query "
        CREATE TABLE gova11y.migrations
        (
            migration_name String,
            applied_at DateTime DEFAULT now()
        )
        ENGINE = MergeTree
        ORDER BY migration_name
        SETTINGS index_granularity = 8192;"
    if [ $? -ne 0 ]; then
        echo "Error creating migrations table."
        exit 1
    fi
fi

# Loop through migration scripts in order
for migration in $(ls $MIGRATIONS_DIR | sort); do
    # Check if the migration has been applied already
    applied=$(clickhouse-client --query "SELECT 1 FROM gova11y.migrations WHERE migration_name='$migration'")
    if [[ "$applied" != "1" ]]; then
        clickhouse-client < "$MIGRATIONS_DIR/$migration"
        if [ $? -ne 0 ]; then
            echo "Error applying migration $migration"
            exit 1
        else
            echo "Applied migration $migration"
            clickhouse-client --query "INSERT INTO gova11y.migrations (migration_name) VALUES ('$migration')"
            if [ $? -ne 0 ]; then
                echo "Error recording migration $migration"
                exit 1
            fi
        fi
    else
        echo "Migration $migration already applied, skipping"
    fi
done
