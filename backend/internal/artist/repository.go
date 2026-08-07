package artist

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("artist not found")

type Repository interface {
	Create(ctx context.Context, name, bio, imageURL string, ownerUserID *string) (Artist, error)
	GetByID(ctx context.Context, id string) (Artist, error)
	GetByOwner(ctx context.Context, ownerUserID string) (Artist, error)
	List(ctx context.Context, limit, offset int) ([]Artist, error)
	Update(ctx context.Context, id, name, bio, imageURL string) (Artist, error)
	Delete(ctx context.Context, id string) error
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Create(ctx context.Context, name, bio, imageURL string, ownerUserID *string) (Artist, error) {
	query := `
		INSERT INTO artists (name, bio, image_url, owner_user_id)
		VALUES ($1, $2, $3, $4)
		RETURNING id, name, COALESCE(bio, ''), COALESCE(image_url, ''), verified, followers_count, owner_user_id, created_at
	`
	row := r.db.QueryRow(ctx, query, name, bio, imageURL, ownerUserID)

	var a Artist
	err := row.Scan(&a.ID, &a.Name, &a.Bio, &a.ImageURL, &a.Verified, &a.FollowersCount, &a.OwnerUserID, &a.CreatedAt)
	return a, err
}

func (r *postgresRepository) GetByID(ctx context.Context, id string) (Artist, error) {
	query := `SELECT id, name, COALESCE(bio, ''), COALESCE(image_url, ''), verified, followers_count, owner_user_id, created_at FROM artists WHERE id = $1`
	row := r.db.QueryRow(ctx, query, id)

	var a Artist
	err := row.Scan(&a.ID, &a.Name, &a.Bio, &a.ImageURL, &a.Verified, &a.FollowersCount, &a.OwnerUserID, &a.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return Artist{}, ErrNotFound
	}
	return a, err
}

func (r *postgresRepository) GetByOwner(ctx context.Context, ownerUserID string) (Artist, error) {
	query := `SELECT id, name, COALESCE(bio, ''), COALESCE(image_url, ''), verified, followers_count, owner_user_id, created_at FROM artists WHERE owner_user_id = $1`
	row := r.db.QueryRow(ctx, query, ownerUserID)

	var a Artist
	err := row.Scan(&a.ID, &a.Name, &a.Bio, &a.ImageURL, &a.Verified, &a.FollowersCount, &a.OwnerUserID, &a.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return Artist{}, ErrNotFound
	}
	return a, err
}

func (r *postgresRepository) List(ctx context.Context, limit, offset int) ([]Artist, error) {
	query := `SELECT id, name, COALESCE(bio, ''), COALESCE(image_url, ''), verified, followers_count, owner_user_id, created_at FROM artists ORDER BY created_at DESC LIMIT $1 OFFSET $2`
	rows, err := r.db.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var artists []Artist
	for rows.Next() {
		var a Artist
		if err := rows.Scan(&a.ID, &a.Name, &a.Bio, &a.ImageURL, &a.Verified, &a.FollowersCount, &a.OwnerUserID, &a.CreatedAt); err != nil {
			return nil, err
		}
		artists = append(artists, a)
	}
	if artists == nil {
		artists = []Artist{}
	}
	return artists, nil
}

func (r *postgresRepository) Update(ctx context.Context, id, name, bio, imageURL string) (Artist, error) {
	query := `
		UPDATE artists SET name = $2, bio = $3, image_url = $4
		WHERE id = $1
		RETURNING id, name, COALESCE(bio, ''), COALESCE(image_url, ''), verified, followers_count, owner_user_id, created_at
	`
	row := r.db.QueryRow(ctx, query, id, name, bio, imageURL)

	var a Artist
	err := row.Scan(&a.ID, &a.Name, &a.Bio, &a.ImageURL, &a.Verified, &a.FollowersCount, &a.OwnerUserID, &a.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return Artist{}, ErrNotFound
	}
	return a, err
}

func (r *postgresRepository) Delete(ctx context.Context, id string) error {
	_, err := r.db.Exec(ctx, `DELETE FROM artists WHERE id = $1`, id)
	return err
}
