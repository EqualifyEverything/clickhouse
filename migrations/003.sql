-- Migrations: 003
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
