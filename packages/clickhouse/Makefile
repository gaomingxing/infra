# 部署前环境中需要安装go（go1.24.7）跟docker（28.2.2）
# Load environment variables from root .env file
-include ../../.env

# CLICKHOUSE_DATABASE = dev_e2b_clickhouse# dev database

# Set default values for ClickHouse variables
CLICKHOUSE_USERNAME ?= default
CLICKHOUSE_PASSWORD ?=
CLICKHOUSE_HOST ?= localhost
CLICKHOUSE_PORT ?= 9000
CLICKHOUSE_DATABASE ?= dev_e2b_clickhouse

# Local development configuration
CLICKHOUSE_CONTAINER_NAME = clickhouse

.PHONY: all
all: run migrate

.PHONY: run
run:
	# Fill in the variables in the config file
	PASSWORD="$(CLICKHOUSE_PASSWORD)" \
 	USERNAME="$(CLICKHOUSE_USERNAME)" \
 	PORT="$(CLICKHOUSE_PORT)" \
	envsubst < ./local/config.tpl.xml > "./local/config.xml"

	# Fill in the variables in the users file
	PASSWORD="$(CLICKHOUSE_PASSWORD)" \
	USERNAME="$(CLICKHOUSE_USERNAME)" \
	envsubst < ./local/users.tpl.xml > "./local/users.xml"

	chmod 644 ./local/config.xml
	chmod 644 ./local/users.xml

	docker network create e2b || true
	docker run -d --name $(CLICKHOUSE_CONTAINER_NAME) \
				--network e2b \
				-p 9000:9000 \
				-p 8123:8123 \
				--health-cmd="clickhouse-client --query 'SELECT 1'" \
				--health-interval=5s \
				--health-timeout=2s \
				--health-retries=5 \
				--log-driver json-file \
				--log-opt max-size=100m \
				--log-opt max-file=3 \
				--restart unless-stopped \
				-v ./local/users.xml:/etc/clickhouse-server/users.d/users.xml \
				-v ./local/config.xml:/etc/clickhouse-server/config.d/config.xml \
				clickhouse/clickhouse-server:25.4.5.24

	# Wait for ClickHouse to be healthy
	@echo "等待ClickHouse服务启动..."
	@docker wait --condition=healthy $(CLICKHOUSE_CONTAINER_NAME) 2>/dev/null || true

.PHONY: stop
stop:
	docker stop $(CLICKHOUSE_CONTAINER_NAME) || true
	docker rm $(CLICKHOUSE_CONTAINER_NAME) || true

.PHONY: migrate
migrate: install-goose create-database run-migrations

.PHONY: install-goose
install-goose:
	@echo "检查goose是否已安装..."
	@if ! $$(go env GOPATH)/bin/goose version > /dev/null 2>&1; then \
		echo "安装goose迁移工具..."; \
		go install github.com/pressly/goose/v3/cmd/goose@v3.24.2; \
	else \
		echo "goose已存在，跳过安装"; \
	fi

.PHONY: create-database
create-database:
	@echo "创建数据库 ${CLICKHOUSE_DATABASE}（如果不存在）..."
	@docker exec $(CLICKHOUSE_CONTAINER_NAME) \
		clickhouse-client \
		--user=$(CLICKHOUSE_USERNAME) \
		$(if $(CLICKHOUSE_PASSWORD),--password=$(CLICKHOUSE_PASSWORD)) \
		--query="CREATE DATABASE IF NOT EXISTS ${CLICKHOUSE_DATABASE}"
	@echo "数据库创建完成"

.PHONY: run-migrations
run-migrations: install-goose
	@echo "执行ClickHouse数据库迁移..."
	@echo "GOPATH: $$(go env GOPATH)"
	@echo "GOOSE路径: $$(go env GOPATH)/bin/goose"
	@echo "连接字符串: clickhouse://${CLICKHOUSE_USERNAME}:${CLICKHOUSE_PASSWORD}@localhost:${CLICKHOUSE_PORT}/${CLICKHOUSE_DATABASE}"
	@export GOOSE_DBSTRING="clickhouse://${CLICKHOUSE_USERNAME}:${CLICKHOUSE_PASSWORD}@localhost:${CLICKHOUSE_PORT}/${CLICKHOUSE_DATABASE}" && \
	export GOOSE_DRIVER=clickhouse && \
	$$(go env GOPATH)/bin/goose -dir ./migrations up
	@echo "迁移完成"

.PHONY: clean
clean: stop
	rm -f ./local/config.xml ./local/users.xml

.PHONY: connect
connect:
	@docker exec -it $(CLICKHOUSE_CONTAINER_NAME) \
		clickhouse-client \
		--user=$(CLICKHOUSE_USERNAME) \
		$(if $(CLICKHOUSE_PASSWORD),--password=$(CLICKHOUSE_PASSWORD)) \
		--database=$(CLICKHOUSE_DATABASE)