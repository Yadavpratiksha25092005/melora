package admin

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	Dashboard(ctx context.Context) (DashboardResponse, error)
	ListUsers(ctx context.Context, limit, offset int) ([]UserResponse, error)
	DeleteUser(ctx context.Context, id string) error
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Dashboard(ctx context.Context) (DashboardResponse, error) {
	var d DashboardResponse

	if err := r.db.QueryRow(ctx, `SELECT COUNT(*) FROM users`).Scan(&d.TotalUsers); err != nil {
		return d, err
	}
	if err := r.db.QueryRow(ctx, `SELECT COUNT(*) FROM songs`).Scan(&d.TotalSongs); err != nil {
		return d, err
	}
	if err := r.db.QueryRow(ctx, `SELECT COUNT(*) FROM artists`).Scan(&d.TotalArtists); err != nil {
		return d, err
	}
	if err := r.db.QueryRow(ctx, `SELECT COUNT(*) FROM albums`).Scan(&d.TotalAlbums); err != nil {
		return d, err
	}
	if err := r.db.QueryRow(ctx, `SELECT COUNT(*) FROM songs WHERE status = 'UNDER_REVIEW'`).Scan(&d.PendingSongs); err != nil {
		return d, err
	}

	return d, nil
}

func (r *postgresRepository) ListUsers(ctx context.Context, limit, offset int) ([]UserResponse, error) {
	if limit <= 0 {
		limit = 20
	}
	query := `SELECT id, COALESCE(name, ''), phone_number, is_admin FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2`
	rows, err := r.db.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []UserResponse
	for rows.Next() {
		var u UserResponse
		if err := rows.Scan(&u.ID, &u.Name, &u.PhoneNumber, &u.IsAdmin); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	if users == nil {
		users = []UserResponse{}
	}
	return users, nil
}

func (r *postgresRepository) DeleteUser(ctx context.Context, id string) error {
	_, err := r.db.Exec(ctx, `DELETE FROM users WHERE id = $1`, id)
	return err
}
