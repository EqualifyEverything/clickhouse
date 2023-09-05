-- Migrations: 002
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
