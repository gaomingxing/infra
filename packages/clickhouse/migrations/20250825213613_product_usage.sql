-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS product_usage ON CLUSTER 'cluster' as product_usage_local
    ENGINE = Distributed('cluster', currentDatabase(), 'product_usage_local', xxHash64(team_id));
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS product_usage ON CLUSTER 'cluster';
-- +goose StatementEnd