package history

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	Add(ctx context.Context, userID, songID string) error
	ListByUser(ctx context.Context, userID string, limit int) ([]HistorySong, error)
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Add(ctx context.Context, userID, songID string) error {
	query := `INSERT INTO listen_history (user_id, song_id) VALUES ($1, $2)`
	_, err := r.db.Exec(ctx, query, userID, songID)
	return err
}

func (r *postgresRepository) ListByUser(ctx context.Context, userID string, limit int) ([]HistorySong, error) {
	query := `
		SELECT s.id, s.album_id, s.artist_id, s.title, s.duration_ms, s.file_url, COALESCE(s.cover_url, ''), COALESCE(s.genre, ''), h.played_at
		FROM listen_history h
		JOIN songs s ON s.id = h.song_id
		WHERE h.user_id = $1
		ORDER BY h.played_at DESC
		LIMIT $2
	`
	rows, err := r.db.Query(ctx, query, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var songs []HistorySong
	for rows.Next() {
		var s HistorySong
		var playedAt time.Time
		if err := rows.Scan(&s.ID, &s.AlbumID, &s.ArtistID, &s.Title, &s.DurationMs, &s.FileURL, &s.CoverURL, &s.Genre, &playedAt); err != nil {
			return nil, err
		}
		s.PlayedAt = playedAt.Format(time.RFC3339)
		songs = append(songs, s)
	}
	if songs == nil {
		songs = []HistorySong{}
	}
	return songs, nil
}
