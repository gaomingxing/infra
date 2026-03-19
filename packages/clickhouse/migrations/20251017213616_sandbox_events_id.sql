-- +goose Up

-- ID field with default UUID for local
ALTER TABLE sandbox_events_local ON CLUSTER 'cluster'
    ADD COLUMN id UUID DEFAULT generateUUIDv4();

-- ID field with default UUID for global
ALTER TABLE sandbox_events ON CLUSTER 'cluster'
    ADD COLUMN id UUID DEFAULT generateUUIDv4();

-- +goose Down
-- Remove ID column from local
ALTER TABLE sandbox_events_local ON CLUSTER 'cluster'
DROP COLUMN IF EXISTS id;

-- Remove ID column from global
ALTER TABLE sandbox_events ON CLUSTER 'cluster'
DROP COLUMN IF EXISTS id;