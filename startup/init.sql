-- GovA11y ClickHouse Setup Script

CREATE DATABASE ${CLICKHOUSE_DB};

-- Create GovA11y User & Grant Perms
CREATE USER ${CLICKHOUSE_USER} IDENTIFIED WITH plaintext_password BY '${CLICKHOUSE_PASSWORD}';
GRANT ALL ON gova11y.* TO a11ypython;


-- Create axe_tests table
CREATE TABLE gova11y.axe_tests
(
    `domain_id` Int32,
    `domain` String,
    `url_id` Int64,
    `url` String,
    `scan_id` Int64,
    `rule_id` Int64,
    `test_id` UUID DEFAULT generateUUIDv4(),
    `tested_at` DateTime,
    `rule_type` String,
    `axe_id` String,
    `impact` String,
    `target` String,
    `html` String,
    `failure_summary` Nullable(String),
    `created_at` DateTime DEFAULT now(),
    `active` UInt8 DEFAULT 1,
    `section508` UInt8 DEFAULT 0,
    `super_waggy` UInt8 DEFAULT 0
)
ENGINE = MergeTree
ORDER BY test_id
SETTINGS index_granularity = 8192;

-- Create Recent Tests Table
-- gova11y.axe_tests_recent source

CREATE MATERIALIZED VIEW gova11y.axe_tests_recent
(
    `url_id` Int64,
    `axe_id` String,
    `target` String,
    `url` String,
    `test_id` UUID,
    `tested_at` DateTime,
    `domain_id` Int32,
    `domain` String,
    `scan_id` Int64,
    `rule_id` Int64,
    `rule_type` String,
    `impact` String,
    `html` String,
    `failure_summary` Nullable(String),
    `created_at` DateTime,
    `active` UInt8,
    `section508` UInt8,
    `super_waggy` UInt8
)
ENGINE = MergeTree
ORDER BY (url_id,
 axe_id,
 target,
 tested_at)
SETTINGS index_granularity = 8192 AS
SELECT
    url_id,
    axe_id,
    target,
    url,
    test_id,
    tested_at,
    domain_id,
    domain,
    scan_id,
    rule_id,
    rule_type,
    impact,
    html,
    failure_summary,
    created_at,
    active,
    section508,
    super_waggy
FROM
(
    SELECT
        url_id,
        axe_id,
        target,
        url,
        test_id,
        tested_at,
        domain_id,
        domain,
        scan_id,
        rule_id,
        rule_type,
        impact,
        html,
        failure_summary,
        created_at,
        active,
        section508,
        super_waggy,
        row_number() OVER (PARTITION BY url_id,
 axe_id,
 target ORDER BY tested_at DESC) AS row_num
    FROM gova11y.axe_tests
) AS subquery
WHERE row_num = 1;

-- Create Recent Tests Score Table
-- gova11y.axe_tests_recent_score definition

CREATE TABLE gova11y.axe_tests_recent_score
(
    `domain` String,
    `url` String,
    `axe_id` String,
    `rule_type` String,
    `impact` String,
    `count_tests` Int64,
    `created_at` DateTime DEFAULT now(),
    `updated_at` DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY (domain,
 url,
 axe_id,
 rule_type,
 impact)
SETTINGS index_granularity = 8192;