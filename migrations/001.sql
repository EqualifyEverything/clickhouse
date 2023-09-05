-- Migrations: 001
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
