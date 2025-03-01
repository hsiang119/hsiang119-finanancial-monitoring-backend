.PHONY: fmt lint test build

fmt:
	go fmt ./...

lint:
	golangci-lint run

test:
	go test -v ./...

build:
	go build -o bin/server .

all: fmt lint test build