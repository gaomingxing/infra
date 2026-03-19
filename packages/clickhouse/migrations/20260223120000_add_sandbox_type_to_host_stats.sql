-- +goose Up
-- +goose StatementBegin
ALTER TABLE sandbox_host_stats_local ON CLUSTER 'cluster'
    ADD COLUMN IF NOT EXISTS sandbox_type LowCardinality(String) DEFAULT 'sandbox' CODEC (ZSTD(1));
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE sandbox_host_stats ON CLUSTER 'cluster'
    ADD COLUMN IF NOT EXISTS sandbox_type LowCardinality(String) DEFAULT 'sandbox' CODEC (ZSTD(1));
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE sandbox_host_stats_local ON CLUSTER 'cluster' DROP COLUMN IF EXISTS sandbox_type;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE sandbox_host_stats ON CLUSTER 'cluster' DROP COLUMN IF EXISTS sandbox_type;
-- +goose StatementEnd