package podcast

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("not found")

type Repository interface {
	CreateShow(ctx context.Context, s Show) (Show, error)
	ListShows(ctx context.Context, limit, offset int) ([]Show, error)
	ListShowsByCreator(ctx context.Context, creatorUserID string, limit, offset int) ([]Show, error)
	GetShow(ctx context.Context, id string) (Show, error)

	CreateEpisode(ctx context.Context, e Episode) (Episode, error)
	ListEpisodesByShow(ctx context.Context, showID string) ([]Episode, error)
	GetEpisode(ctx context.Context, id string) (Episode, error)
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) CreateShow(ctx context.Context, s Show) (Show, error) {
	query := `
		INSERT INTO shows (title, host_name, description, cover_url, creator_user_id)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, title, COALESCE(host_name, ''), COALESCE(description, ''), COALESCE(cover_url, ''), creator_user_id, created_at
	`
	row := r.db.QueryRow(ctx, query, s.Title, s.HostName, s.Description, s.CoverURL, s.CreatorUserID)
	var out Show
	err := row.Scan(&out.ID, &out.Title, &out.HostName, &out.Description, &out.CoverURL, &out.CreatorUserID, &out.CreatedAt)
	return out, err
}

func (r *postgresRepository) ListShows(ctx context.Context, limit, offset int) ([]Show, error) {
	query := `SELECT id, title, COALESCE(host_name, ''), COALESCE(description, ''), COALESCE(cover_url, ''), creator_user_id, created_at FROM shows ORDER BY created_at DESC LIMIT $1 OFFSET $2`
	rows, err := r.db.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var shows []Show
	for rows.Next() {
		var s Show
		if err := rows.Scan(&s.ID, &s.Title, &s.HostName, &s.Description, &s.CoverURL, &s.CreatorUserID, &s.CreatedAt); err != nil {
			return nil, err
		}
		shows = append(shows, s)
	}
	if shows == nil {
		shows = []Show{}
	}
	return shows, nil
}

func (r *postgresRepository) ListShowsByCreator(ctx context.Context, creatorUserID string, limit, offset int) ([]Show, error) {
	if limit <= 0 {
		limit = 50
	}
	query := `SELECT id, title, COALESCE(host_name, ''), COALESCE(description, ''), COALESCE(cover_url, ''), creator_user_id, created_at FROM shows WHERE creator_user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`
	rows, err := r.db.Query(ctx, query, creatorUserID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var shows []Show
	for rows.Next() {
		var s Show
		if err := rows.Scan(&s.ID, &s.Title, &s.HostName, &s.Description, &s.CoverURL, &s.CreatorUserID, &s.CreatedAt); err != nil {
			return nil, err
		}
		shows = append(shows, s)
	}
	if shows == nil {
		shows = []Show{}
	}
	return shows, nil
}

func (r *postgresRepository) GetShow(ctx context.Context, id string) (Show, error) {
	query := `SELECT id, title, COALESCE(host_name, ''), COALESCE(description, ''), COALESCE(cover_url, ''), creator_user_id, created_at FROM shows WHERE id = $1`
	row := r.db.QueryRow(ctx, query, id)
	var s Show
	err := row.Scan(&s.ID, &s.Title, &s.HostName, &s.Description, &s.CoverURL, &s.CreatorUserID, &s.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return Show{}, ErrNotFound
	}
	return s, err
}

func (r *postgresRepository) CreateEpisode(ctx context.Context, e Episode) (Episode, error) {
	query := `
		INSERT INTO episodes (show_id, title, description, audio_url, video_url, cover_url, duration_ms, episode_number)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, show_id, title, COALESCE(description, ''), COALESCE(audio_url, ''), COALESCE(video_url, ''), COALESCE(cover_url, ''), COALESCE(duration_ms, 0), COALESCE(episode_number, 0), created_at
	`
	row := r.db.QueryRow(ctx, query, e.ShowID, e.Title, e.Description, e.AudioURL, e.VideoURL, e.CoverURL, e.DurationMs, e.EpisodeNumber)
	var out Episode
	err := row.Scan(&out.ID, &out.ShowID, &out.Title, &out.Description, &out.AudioURL, &out.VideoURL, &out.CoverURL, &out.DurationMs, &out.EpisodeNumber, &out.CreatedAt)
	return out, err
}

func (r *postgresRepository) ListEpisodesByShow(ctx context.Context, showID string) ([]Episode, error) {
	query := `
		SELECT id, show_id, title, COALESCE(description, ''), COALESCE(audio_url, ''), COALESCE(video_url, ''), COALESCE(cover_url, ''), COALESCE(duration_ms, 0), COALESCE(episode_number, 0), created_at
		FROM episodes WHERE show_id = $1 ORDER BY episode_number ASC, created_at ASC
	`
	rows, err := r.db.Query(ctx, query, showID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var episodes []Episode
	for rows.Next() {
		var e Episode
		if err := rows.Scan(&e.ID, &e.ShowID, &e.Title, &e.Description, &e.AudioURL, &e.VideoURL, &e.CoverURL, &e.DurationMs, &e.EpisodeNumber, &e.CreatedAt); err != nil {
			return nil, err
		}
		episodes = append(episodes, e)
	}
	if episodes == nil {
		episodes = []Episode{}
	}
	return episodes, nil
}

func (r *postgresRepository) GetEpisode(ctx context.Context, id string) (Episode, error) {
	query := `
		SELECT id, show_id, title, COALESCE(description, ''), COALESCE(audio_url, ''), COALESCE(video_url, ''), COALESCE(cover_url, ''), COALESCE(duration_ms, 0), COALESCE(episode_number, 0), created_at
		FROM episodes WHERE id = $1
	`
	row := r.db.QueryRow(ctx, query, id)
	var e Episode
	err := row.Scan(&e.ID, &e.ShowID, &e.Title, &e.Description, &e.AudioURL, &e.VideoURL, &e.CoverURL, &e.DurationMs, &e.EpisodeNumber, &e.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return Episode{}, ErrNotFound
	}
	return e, err
}
