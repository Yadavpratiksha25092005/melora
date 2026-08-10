package album

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("album not found")

type Repository interface {
	Create(ctx context.Context, artistID, title, coverURL string, releasedAt *time.Time) (Album, error)
	GetByID(ctx context.Context, id string) (Album, error)
	List(ctx context.Context, limit, offset int) ([]Album, error)
	Update(ctx context.Context, id, title, coverURL string, releasedAt *time.Time) (Album, error)
	Delete(ctx context.Context, id string) error
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Create(ctx context.Context, artistID, title, coverURL string, releasedAt *time.Time) (Album, error) {
	query := `
		INSERT INTO albums (artist_id, title, cover_url, released_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, artist_id, title, COALESCE(cover_url, ''), released_at, created_at
	`
	row := r.db.QueryRow(ctx, query, artistID, title, coverURL, releasedAt)

	var a Album
	err := row.Scan(&a.ID, &a.ArtistID, &a.Title, &a.CoverURL, &a.ReleasedAt, &a.CreatedAt)
	return a, err
}

func (r *postgresRepository) GetByID(ctx context.Context, id string) (Album, error) {
	query := `SELECT id, artist_id, title, COALESCE(cover_url, ''), released_at, created_at FROM albums WHERE id = $1`
	row := r.db.QueryRow(ctx, query, id)

	var a Album
	err := row.Scan(&a.ID, &a.ArtistID, &a.Title, &a.CoverURL, &a.ReleasedAt, &a.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return Album{}, ErrNotFound
	}
	return a, err
}

func (r *postgresRepository) List(ctx context.Context, limit, offset int) ([]Album, error) {
	query := `SELECT id, artist_id, title, COALESCE(cover_url, ''), released_at, created_at FROM albums ORDER BY created_at DESC LIMIT $1 OFFSET $2`
	rows, err := r.db.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var albums []Album
	for rows.Next() {
		var a Album
		if err := rows.Scan(&a.ID, &a.ArtistID, &a.Title, &a.CoverURL, &a.ReleasedAt, &a.CreatedAt); err != nil {
			return nil, err
		}
		albums = append(albums, a)
	}
	return albums, nil
}

func (r *postgresRepository) Update(ctx context.Context, id, title, coverURL string, releasedAt *time.Time) (Album, error) {
	query := `
		UPDATE albums SET title = $2, cover_url = $3, released_at = $4
		WHERE id = $1
		RETURNING id, artist_id, title, COALESCE(cover_url, ''), released_at, created_at
	`
	row := r.db.QueryRow(ctx, query, id, title, coverURL, releasedAt)

	var a Album
	err := row.Scan(&a.ID, &a.ArtistID, &a.Title, &a.CoverURL, &a.ReleasedAt, &a.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return Album{}, ErrNotFound
	}
	return a, err
}

func (r *postgresRepository) Delete(ctx context.Context, id string) error {
	_, err := r.db.Exec(ctx, `DELETE FROM albums WHERE id = $1`, id)
	return err
}
