# 第一階段：使用最新版 Go 映像檔作為構建環境
FROM golang:1.22-alpine AS builder

# 設置工作目錄
WORKDIR /app

# 複製 go.mod 和 go.sum 文件
COPY go.mod go.sum* ./

# 下載依賴
RUN go mod download

# 複製源代碼
COPY . .

# 構建應用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server ./cmd/server

# 第二階段：使用精簡的 Alpine 映像檔
FROM alpine:latest

# 安裝 CA 證書
RUN apk --no-cache add ca-certificates tzdata

# 設置時區為台北時間
ENV TZ=Asia/Taipei

# 創建非 root 用戶
RUN adduser -D appuser
USER appuser

# 設置工作目錄
WORKDIR /app

# 從構建階段複製二進位檔案
COPY --from=builder /app/server /app/
COPY --from=builder /app/configs /app/configs

# 暴露端口
EXPOSE 8080

# 設置健康檢查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost:8080/health || exit 1

# 設置啟動命令
CMD ["./server"]
