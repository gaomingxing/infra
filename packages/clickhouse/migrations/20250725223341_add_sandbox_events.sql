-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS sandbox_events ON CLUSTER 'cluster' as sandbox_events_local
    ENGINE = Distributed('cluster', currentDatabase(), 'sandbox_events_local', xxHash64(sandbox_id));
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS sandbox_events ON CLUSTER 'cluster';
-- +goose StatementEnd