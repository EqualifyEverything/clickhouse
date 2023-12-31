# Clickhouse custom docker image for GovA11y
# Start from the latest ClickHouse image
FROM clickhouse/clickhouse-server:latest

# Copy startup initialization script
COPY startup/ /docker-entrypoint-initdb.d/

# Copy configuration files directly into /etc/clickhouse-server/
COPY config/ /etc/clickhouse-server/

# Copy & Setup Migrations
COPY migrations/ /etc/clickhouse-server/migrations/


# Ensure init.sh is executable
RUN chmod +x /docker-entrypoint-initdb.d/init.sh


# Define a volume for the data
VOLUME /var/lib/clickhouse

# Define a volume for the logs
VOLUME /var/log/clickhouse-server

# Create GovA11y
# ENV CLICKHOUSE_DB=gova11y
ENV CLICKHOUSE_USER=ChangeMe
ENV CLICKHOUSE_PASSWORD=PleaseChangeMe
ENV CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT=1

# Set default Sentry reporting
ENV SENTRY_DSN="https://29247ae8984e5ab904e5ca6daba80497@sentry.beltway.cloud/16"
ENV SENTRY_ANONYMIZE=true
ENV SEND_CRASH_REPORTS=true

# Do some housekeeping
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TZ=UTC

# Expose ports
EXPOSE 8123
EXPOSE 9000
EXPOSE 9005


# Health Check
# Install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
# Define Health Check
HEALTHCHECK --start-period=15s --interval=10s --timeout=5s --retries=5 \
  CMD curl -f http://localhost:8123/ping || exit 1

# Define the command to start ClickHouse
ENTRYPOINT ["/entrypoint.sh"]
