-- +goose Up

-- Drop and recreate materialized view instead of MODIFY QUERY
DROP TABLE IF EXISTS sandbox_metrics_gauge_mv;
CREATE MATERIALIZED VIEW sandbox_metrics_gauge_mv
TO sandbox_metrics_gauge AS SELECT
    toDateTime64(TimeUnix, 9) AS timestamp,
    Attributes['sandbox_id'] AS sandbox_id,
    Attributes['team_id'] AS team_id,
    MetricName AS metric_name,
    Value AS value
FROM metrics_gauge
WHERE MetricName LIKE 'e2b.sandbox.%';


-- +goose Down
-- Drop and recreate materialized view instead of MODIFY QUERY
DROP TABLE IF EXISTS sandbox_metrics_gauge_mv;
CREATE MATERIALIZED VIEW sandbox_metrics_gauge_mv
TO sandbox_metrics_gauge AS SELECT
  TimeUnix AS timestamp,
  Attributes['sandbox_id'] AS sandbox_id,
  Attributes['team_id'] AS team_id,
  MetricName AS metric_name,
  Value AS value
FROM metrics_gauge_local WHERE Attributes['sandbox_id'] IS NOT NULL;