-- +goose Up
-- +goose StatementBegin
ALTER TABLE sandbox_metrics_gauge_local ON CLUSTER 'cluster'
    ADD COLUMN IF NOT EXISTS build_id String DEFAULT '' CODEC (ZSTD(1)),
    ADD COLUMN IF NOT EXISTS sandbox_type LowCardinality(String) DEFAULT 'sandbox' CODEC (ZSTD(1));
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE sandbox_metrics_gauge ON CLUSTER 'cluster'
    ADD COLUMN IF NOT EXISTS build_id String DEFAULT '' CODEC (ZSTD(1)),
    ADD COLUMN IF NOT EXISTS sandbox_type LowCardinality(String) DEFAULT 'sandbox' CODEC (ZSTD(1));
-- +goose StatementEnd

-- +goose StatementBegin
-- Drop materialized view
DROP TABLE IF EXISTS sandbox_metrics_gauge_mv ON CLUSTER 'cluster';
-- +goose StatementEnd

-- +goose StatementBegin
-- Create materialized view
CREATE MATERIALIZED VIEW sandbox_metrics_gauge_mv ON CLUSTER 'cluster'
TO sandbox_metrics_gauge AS SELECT
    toDateTime64(TimeUnix, 9) AS timestamp,
    Attributes['sandbox_id'] AS sandbox_id,
    Attributes['team_id'] AS team_id,
    Attributes['build_id'] AS build_id,
    Attributes['sandbox_type'] AS sandbox_type,
    MetricName AS metric_name,
    Value AS value
FROM metrics_gauge
WHERE MetricName LIKE 'e2b.sandbox.%';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Drop materialized view
DROP TABLE IF EXISTS sandbox_metrics_gauge_mv ON CLUSTER 'cluster';
-- +goose StatementEnd

-- +goose StatementBegin
-- Create materialized view
CREATE MATERIALIZED VIEW sandbox_metrics_gauge_mv ON CLUSTER 'cluster'
TO sandbox_metrics_gauge AS SELECT
    toDateTime64(TimeUnix, 9) AS timestamp,
    Attributes['sandbox_id'] AS sandbox_id,
    Attributes['team_id'] AS team_id,
    MetricName AS metric_name,
    Value AS value
FROM metrics_gauge
WHERE MetricName LIKE 'e2b.sandbox.%';
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE sandbox_metrics_gauge_local ON CLUSTER 'cluster'
    DROP COLUMN IF EXISTS build_id,
    DROP COLUMN IF EXISTS sandbox_type;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE sandbox_metrics_gauge ON CLUSTER 'cluster'
    DROP COLUMN IF EXISTS build_id,
    DROP COLUMN IF EXISTS sandbox_type;
-- +goose StatementEnd