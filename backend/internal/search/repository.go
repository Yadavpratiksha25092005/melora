package search

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	SearchSongs(ctx context.Context, query string, limit int) ([]SongResult, error)
	SearchArtists(ctx context.Context, query string, limit int) ([]ArtistResult, error)
	SearchAlbums(ctx context.Context, query string, limit int) ([]AlbumResult, error)
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) SearchSongs(ctx context.Context, query string, limit int) ([]SongResult, error) {
	sql := `
		SELECT id, title, artist_id, COALESCE(cover_url, '')
		FROM songs
		WHERE title ILIKE '%' || $1 || '%'
		ORDER BY title
		LIMIT $2
	`
	rows, err := r.db.Query(ctx, sql, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []SongResult
	for rows.Next() {
		var s SongResult
		if err := rows.Scan(&s.ID, &s.Title, &s.ArtistID, &s.CoverURL); err != nil {
			return nil, err
		}
		results = append(results, s)
	}
	if results == nil {
		results = []SongResult{}
	}
	return results, nil
}

func (r *postgresRepository) SearchArtists(ctx context.Context, query string, limit int) ([]ArtistResult, error) {
	sql := `
		SELECT id, name, COALESCE(image_url, '')
		FROM artists
		WHERE name ILIKE '%' || $1 || '%'
		ORDER BY name
		LIMIT $2
	`
	rows, err := r.db.Query(ctx, sql, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []ArtistResult
	for rows.Next() {
		var a ArtistResult
		if err := rows.Scan(&a.ID, &a.Name, &a.ImageURL); err != nil {
			return nil, err
		}
		results = append(results, a)
	}
	if results == nil {
		results = []ArtistResult{}
	}
	return results, nil
}

func (r *postgresRepository) SearchAlbums(ctx context.Context, query string, limit int) ([]AlbumResult, error) {
	sql := `
		SELECT id, title, artist_id, COALESCE(cover_url, '')
		FROM albums
		WHERE title ILIKE '%' || $1 || '%'
		ORDER BY title
		LIMIT $2
	`
	rows, err := r.db.Query(ctx, sql, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []AlbumResult
	for rows.Next() {
		var a AlbumResult
		if err := rows.Scan(&a.ID, &a.Title, &a.ArtistID, &a.CoverURL); err != nil {
			return nil, err
		}
		results = append(results, a)
	}
	if results == nil {
		results = []AlbumResult{}
	}
	return results, nil
}
