package user

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("user not found")

type Repository interface {
	UpdateProfile(ctx context.Context, id, name, avatarURL string) (UserResponse, error)
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) UpdateProfile(ctx context.Context, id, name, avatarURL string) (UserResponse, error) {
	query := `
		UPDATE users SET name = $2, avatar_url = $3
		WHERE id = $1
		RETURNING id, COALESCE(name, ''), phone_number, COALESCE(avatar_url, '')
	`
	row := r.db.QueryRow(ctx, query, id, name, avatarURL)

	var u UserResponse
	err := row.Scan(&u.ID, &u.Name, &u.PhoneNumber, &u.AvatarURL)
	if errors.Is(err, pgx.ErrNoRows) {
		return UserResponse{}, ErrNotFound
	}
	return u, err
}
