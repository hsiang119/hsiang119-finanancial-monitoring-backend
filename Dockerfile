
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod main.go ./
RUN go mod download
# 禁用 CGO 並針對 Linux 編譯
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server .


FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/server .
EXPOSE 8080
CMD ["./server"]
