package favorite

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	Add(ctx context.Context, userID, songID string) error
	Remove(ctx context.Context, userID, songID string) error
	ListByUser(ctx context.Context, userID string) ([]FavoriteSong, error)
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Add(ctx context.Context, userID, songID string) error {
	query := `
		INSERT INTO favorites (user_id, song_id)
		VALUES ($1, $2)
		ON CONFLICT (user_id, song_id) DO NOTHING
	`
	_, err := r.db.Exec(ctx, query, userID, songID)
	return err
}

func (r *postgresRepository) Remove(ctx context.Context, userID, songID string) error {
	_, err := r.db.Exec(ctx, `DELETE FROM favorites WHERE user_id = $1 AND song_id = $2`, userID, songID)
	return err
}

func (r *postgresRepository) ListByUser(ctx context.Context, userID string) ([]FavoriteSong, error) {
	query := `
		SELECT s.id, s.album_id, s.artist_id, s.title, s.duration_ms, s.file_url, COALESCE(s.cover_url, ''), COALESCE(s.genre, '')
		FROM songs s
		JOIN favorites f ON f.song_id = s.id
		WHERE f.user_id = $1
		ORDER BY f.created_at DESC
	`
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var songs []FavoriteSong
	for rows.Next() {
		var s FavoriteSong
		if err := rows.Scan(&s.ID, &s.AlbumID, &s.ArtistID, &s.Title, &s.DurationMs, &s.FileURL, &s.CoverURL, &s.Genre); err != nil {
			return nil, err
		}
		songs = append(songs, s)
	}
	if songs == nil {
		songs = []FavoriteSong{}
	}
	return songs, nil
}
