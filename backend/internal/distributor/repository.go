package distributor

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	CountDuplicates(ctx context.Context, artistID, title string) (int, error)
	Insert(ctx context.Context, s Song) (string, error)
	ListByStatus(ctx context.Context, status string) ([]PendingSongResponse, error)
	UpdateStatus(ctx context.Context, id, status string) error
}

type Song struct {
	ArtistID   string
	AlbumID    *string
	Title      string
	DurationMs int
	FileURL    string
	CoverURL   string
	Genre      string
	Status     string
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) CountDuplicates(ctx context.Context, artistID, title string) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM songs WHERE artist_id = $1 AND LOWER(title) = LOWER($2)`
	err := r.db.QueryRow(ctx, query, artistID, title).Scan(&count)
	return count, err
}

func (r *postgresRepository) Insert(ctx context.Context, s Song) (string, error) {
	var publishedAt interface{}
	if s.Status == "PUBLISHED" {
		publishedAt = "now()"
	}

	var query string
	var id string
	var err error

	if s.Status == "PUBLISHED" {
		query = `
			INSERT INTO songs (artist_id, album_id, title, duration_ms, file_url, cover_url, genre, status, published_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, now())
			RETURNING id
		`
	} else {
		query = `
			INSERT INTO songs (artist_id, album_id, title, duration_ms, file_url, cover_url, genre, status)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
			RETURNING id
		`
	}

	err = r.db.QueryRow(ctx, query, s.ArtistID, s.AlbumID, s.Title, s.DurationMs, s.FileURL, s.CoverURL, s.Genre, s.Status).Scan(&id)
	_ = publishedAt
	return id, err
}

func (r *postgresRepository) ListByStatus(ctx context.Context, status string) ([]PendingSongResponse, error) {
	query := `SELECT id, title, artist_id, status FROM songs WHERE status = $1 ORDER BY created_at ASC`
	rows, err := r.db.Query(ctx, query, status)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var songs []PendingSongResponse
	for rows.Next() {
		var s PendingSongResponse
		if err := rows.Scan(&s.ID, &s.Title, &s.ArtistID, &s.Status); err != nil {
			return nil, err
		}
		songs = append(songs, s)
	}
	if songs == nil {
		songs = []PendingSongResponse{}
	}
	return songs, nil
}

func (r *postgresRepository) UpdateStatus(ctx context.Context, id, status string) error {
	var query string

	if status == "PUBLISHED" {
		query = `UPDATE songs SET status = $2, published_at = now() WHERE id = $1`
	} else {
		query = `UPDATE songs SET status = $2 WHERE id = $1`
	}

	_, err := r.db.Exec(ctx, query, id, status)
	return err
}
