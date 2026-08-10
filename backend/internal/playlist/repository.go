package playlist

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("playlist not found")

type Repository interface {
	Create(ctx context.Context, userID, name, coverURL string, isPublic bool) (Playlist, error)
	GetByID(ctx context.Context, id string) (Playlist, error)
	ListByUser(ctx context.Context, userID string, limit, offset int) ([]Playlist, error)
	Delete(ctx context.Context, id string) error

	SongsForPlaylist(ctx context.Context, playlistID string) ([]PlaylistSong, error)
	AddSong(ctx context.Context, playlistID, songID string) error
	RemoveSong(ctx context.Context, playlistID, songID string) error
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Create(ctx context.Context, userID, name, coverURL string, isPublic bool) (Playlist, error) {
	query := `
		INSERT INTO playlists (user_id, name, cover_url, is_public)
		VALUES ($1, $2, $3, $4)
		RETURNING id, user_id, name, COALESCE(cover_url, ''), is_public, created_at
	`
	row := r.db.QueryRow(ctx, query, userID, name, coverURL, isPublic)

	var p Playlist
	err := row.Scan(&p.ID, &p.UserID, &p.Name, &p.CoverURL, &p.IsPublic, &p.CreatedAt)
	return p, err
}

func (r *postgresRepository) GetByID(ctx context.Context, id string) (Playlist, error) {
	query := `SELECT id, user_id, name, COALESCE(cover_url, ''), is_public, created_at FROM playlists WHERE id = $1`
	row := r.db.QueryRow(ctx, query, id)

	var p Playlist
	err := row.Scan(&p.ID, &p.UserID, &p.Name, &p.CoverURL, &p.IsPublic, &p.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return Playlist{}, ErrNotFound
	}
	return p, err
}

func (r *postgresRepository) ListByUser(ctx context.Context, userID string, limit, offset int) ([]Playlist, error) {
	query := `SELECT id, user_id, name, COALESCE(cover_url, ''), is_public, created_at FROM playlists WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`
	rows, err := r.db.Query(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var playlists []Playlist
	for rows.Next() {
		var p Playlist
		if err := rows.Scan(&p.ID, &p.UserID, &p.Name, &p.CoverURL, &p.IsPublic, &p.CreatedAt); err != nil {
			return nil, err
		}
		playlists = append(playlists, p)
	}
	return playlists, nil
}

func (r *postgresRepository) Delete(ctx context.Context, id string) error {
	_, err := r.db.Exec(ctx, `DELETE FROM playlists WHERE id = $1`, id)
	return err
}

func (r *postgresRepository) SongsForPlaylist(ctx context.Context, playlistID string) ([]PlaylistSong, error) {
	query := `
		SELECT s.id, s.album_id, s.artist_id, s.title, s.duration_ms, s.file_url, COALESCE(s.cover_url, ''), COALESCE(s.genre, '')
		FROM songs s
		JOIN playlist_songs ps ON ps.song_id = s.id
		WHERE ps.playlist_id = $1
		ORDER BY ps.position ASC, ps.added_at ASC
	`
	rows, err := r.db.Query(ctx, query, playlistID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var songs []PlaylistSong
	for rows.Next() {
		var s PlaylistSong
		if err := rows.Scan(&s.ID, &s.AlbumID, &s.ArtistID, &s.Title, &s.DurationMs, &s.FileURL, &s.CoverURL, &s.Genre); err != nil {
			return nil, err
		}
		songs = append(songs, s)
	}
	return songs, nil
}

func (r *postgresRepository) AddSong(ctx context.Context, playlistID, songID string) error {
	query := `
		INSERT INTO playlist_songs (playlist_id, song_id, position)
		VALUES ($1, $2, (SELECT COALESCE(MAX(position), 0) + 1 FROM playlist_songs WHERE playlist_id = $1))
		ON CONFLICT (playlist_id, song_id) DO NOTHING
	`
	_, err := r.db.Exec(ctx, query, playlistID, songID)
	return err
}

func (r *postgresRepository) RemoveSong(ctx context.Context, playlistID, songID string) error {
	_, err := r.db.Exec(ctx, `DELETE FROM playlist_songs WHERE playlist_id = $1 AND song_id = $2`, playlistID, songID)
	return err
}
