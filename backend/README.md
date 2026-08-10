# Spotify Clone — Backend (Go + PostgreSQL)

## Quick start

```bash
# 1. copy env file
cp .env.example .env

# 2. start postgres + minio
docker-compose up -d postgres minio

# 3. install golang-migrate (once)
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# 4. run migrations
make migrate-up

# 5. run the server
make run
```

Server starts on `http://localhost:8080`. Check `http://localhost:8080/health`.

## Project layout

- `cmd/main.go` — entrypoint, wires everything together
- `config/` — env loading
- `database/` — postgres connection + migrations
- `internal/<feature>/` — one folder per domain (auth, song, playlist, ...),
  each with `model.go`, `dto.go`, `repository.go`, `service.go`, `handler.go`.
  **`internal/song/` is the fully-built reference module — copy its pattern
  for every other feature.**
- `middleware/` — auth, logging, panic recovery, CORS
- `routes/` — one file per feature, mounted in `router.go`
- `pkg/` — shared packages (jwt, s3, logger, response envelope, helpers)

## Adding a new module (e.g. `playlist`)

1. Copy the shape of `internal/song/*.go` into `internal/playlist/`.
2. Write the migration in `database/migration/`.
3. Add `routes/playlist_routes.go`, mount it in `routes/router.go`.
4. Document the endpoints in `docs/openapi.yaml`.

## API contract

See `docs/openapi.yaml` — this is the source of truth shared with the
frontend and testing team. Keep it updated as you add endpoints.

## Response format

Every endpoint returns:

```json
{ "success": true, "data": { ... } }
{ "success": false, "error": { "code": "NOT_FOUND", "message": "..." } }
```
