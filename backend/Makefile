include .env
export

run:
	go run ./cmd/main.go

build:
	go build -o bin/server ./cmd/main.go

test:
	go test ./... -v

migrate-up:
	migrate -path database/migration -database "$(DATABASE_URL)" up

migrate-down:
	migrate -path database/migration -database "$(DATABASE_URL)" down

migrate-create:
	migrate create -ext sql -dir database/migration -seq $(name)

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

tidy:
	go mod tidy
