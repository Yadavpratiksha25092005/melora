package song

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	Create(ctx context.Context, s Song) (Song, error)
	GetByID(ctx context.Context, id string) (Song, error)
	List(ctx context.Context, limit, offset int) ([]Song, error)
	ListByArtist(ctx context.Context, artistID string, limit, offset int) ([]Song, error)
	Delete(ctx context.Context, id string) error
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Create(ctx context.Context, s Song) (Song, error) {
	query := `
		INSERT INTO songs (album_id, artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, COALESCE(NULLIF($10, ''), 'UNDER_REVIEW'), 0)		RETURNING id, album_id, artist_id, title, duration_ms, file_url, cover_url, genre, COALESCE(language, ''), COALESCE(lyrics, ''), status, play_count, created_at
	`
	row := r.db.QueryRow(ctx, query, s.AlbumID, s.ArtistID, s.Title, s.DurationMs, s.FileURL, s.CoverURL, s.Genre, s.Language, s.Lyrics, s.Status)

	var out Song
	err := row.Scan(&out.ID, &out.AlbumID, &out.ArtistID, &out.Title, &out.DurationMs, &out.FileURL, &out.CoverURL, &out.Genre, &out.Language, &out.Lyrics, &out.Status, &out.PlayCount, &out.CreatedAt)
	return out, err
}

func (r *postgresRepository) GetByID(ctx context.Context, id string) (Song, error) {
	query := `SELECT id, album_id, artist_id, title, duration_ms, file_url, cover_url, genre, COALESCE(language, ''), COALESCE(lyrics, ''), status, play_count, created_at FROM songs WHERE id = $1`
	row := r.db.QueryRow(ctx, query, id)

	var out Song
	err := row.Scan(&out.ID, &out.AlbumID, &out.ArtistID, &out.Title, &out.DurationMs, &out.FileURL, &out.CoverURL, &out.Genre, &out.Language, &out.Lyrics, &out.Status, &out.PlayCount, &out.CreatedAt)
	return out, err
}
func (r *postgresRepository) List(ctx context.Context, limit, offset int) ([]Song, error) {
	query := `
		SELECT s.id, s.album_id, s.artist_id, COALESCE(a.name, ''), s.title, s.duration_ms, s.file_url, s.cover_url, s.genre, COALESCE(s.language, ''), COALESCE(s.lyrics, ''), s.status, s.play_count, s.created_at
		FROM songs s
		LEFT JOIN artists a ON a.id = s.artist_id
		ORDER BY s.created_at DESC LIMIT $1 OFFSET $2`
	rows, err := r.db.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var songs []Song
	for rows.Next() {
		var s Song
		if err := rows.Scan(&s.ID, &s.AlbumID, &s.ArtistID, &s.ArtistName, &s.Title, &s.DurationMs, &s.FileURL, &s.CoverURL, &s.Genre, &s.Language, &s.Lyrics, &s.Status, &s.PlayCount, &s.CreatedAt); err != nil {
			return nil, err
		}
		songs = append(songs, s)
	}
	return songs, nil
}
func (r *postgresRepository) Delete(ctx context.Context, id string) error {
	_, err := r.db.Exec(ctx, `DELETE FROM songs WHERE id = $1`, id)
	return err
}

func (r *postgresRepository) ListByArtist(ctx context.Context, artistID string, limit, offset int) ([]Song, error) {
	if limit <= 0 {
		limit = 50
	}
	query := `SELECT id, album_id, artist_id, title, duration_ms, file_url, cover_url, genre, created_at FROM songs WHERE artist_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`
	rows, err := r.db.Query(ctx, query, artistID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var songs []Song
	for rows.Next() {
		var s Song
		if err := rows.Scan(&s.ID, &s.AlbumID, &s.ArtistID, &s.Title, &s.DurationMs, &s.FileURL, &s.CoverURL, &s.Genre, &s.CreatedAt); err != nil {
			return nil, err
		}
		songs = append(songs, s)
	}
	if songs == nil {
		songs = []Song{}
	}
	return songs, nil
}
