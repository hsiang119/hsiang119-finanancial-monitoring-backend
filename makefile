.PHONY: all build run test fmt clean docker docker-compose docker-clean lint migrate migrate-up migrate-down deps

# 變數定義
APP_NAME := financial-monitoring-backend
GO := go
GOTEST := $(GO) test
GOBUILD := $(GO) build
GOMOD := $(GO) mod
GOLINT := golangci-lint
MIGRATION_DIR := migrations

# 預設目標
all: deps lint test

# 下載依賴
deps:
	@echo "下載依賴..."
	$(GOMOD) download

# 建置應用
build:
	@echo "建置應用程式..."
	$(GOBUILD) -o ./bin/$(APP_NAME) ./cmd/server

# 運行應用
run:
	@echo "運行應用程式..."
	$(GO) run ./cmd/server

# 測試
test:
	@echo "運行測試..."
	$(GOTEST) -v ./...

# 格式化代碼
fmt:
	@echo "格式化 Go 代碼..."
	$(GO) fmt ./...

# 測試覆蓋率
test-cover:
	@echo "運行測試覆蓋率..."
	$(GOTEST) -cover -coverprofile=coverage.out ./...
	$(GO) tool cover -html=coverage.out

# 代碼靜態分析
lint:
	@echo "運行靜態代碼分析..."
	$(GOLINT) run

# 清理
clean:
	@echo "清理..."
	rm -rf ./bin
	rm -f coverage.out

# Docker 映像建置
docker:
	@echo "建置 Docker 映像..."
	docker build -t $(APP_NAME) .

# Docker Compose 啟動
docker-compose:
	@echo "啟動 Docker Compose 服務..."
	docker-compose up -d

# Docker Compose 關閉
docker-stop:
	@echo "關閉 Docker Compose 服務..."
	docker-compose down

# 清理 Docker 資源
docker-clean:
	@echo "清理 Docker 資源..."
	docker-compose down --volumes --remove-orphans

# 資料庫遷移相關
migrate-create:
	@read -p "輸入遷移名稱: " name; \
	migrate create -ext sql -dir $(MIGRATION_DIR) -seq $$name

migrate-up:
	@echo "執行遷移升級..."
	migrate -path $(MIGRATION_DIR) -database "postgres://postgres:postgres@localhost:5432/financial_monitoring?sslmode=disable" up

migrate-down:
	@echo "執行遷移降級..."
	migrate -path $(MIGRATION_DIR) -database "postgres://postgres:postgres@localhost:5432/financial_monitoring?sslmode=disable" down

# 幫助
help:
	@echo "可用的 make 指令:"
	@echo "  make deps          - 下載依賴"
	@echo "  make build         - 建置應用程式"
	@echo "  make run           - 運行應用程式"
	@echo "  make test          - 執行測試"
	@echo "  make test-cover    - 測試覆蓋率報告"
	@echo "  make fmt           - 格式化 Go 代碼"
	@echo "  make lint          - 執行代碼靜態分析"
	@echo "  make clean         - 清理生成文件"
	@echo "  make docker        - 建置 Docker 映像"
	@echo "  make docker-compose - 啟動 Docker Compose 服務"
	@echo "  make docker-stop   - 停止 Docker Compose 服務"
	@echo "  make docker-clean  - 清理 Docker 資源"
	@echo "  make migrate-create - 創建一個新的遷移檔案"
	@echo "  make migrate-up    - 執行資料庫遷移升級"
	@echo "  make migrate-down  - 執行資料庫遷移降級"
