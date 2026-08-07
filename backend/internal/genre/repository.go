package genre

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("genre not found")
var ErrNameTaken = errors.New("genre already exists")

type Repository interface {
	Create(ctx context.Context, name string) (Genre, error)
	List(ctx context.Context) ([]Genre, error)
	Delete(ctx context.Context, id string) error
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Create(ctx context.Context, name string) (Genre, error) {
	query := `INSERT INTO genres (name) VALUES ($1) RETURNING id, name, created_at`
	row := r.db.QueryRow(ctx, query, name)

	var g Genre
	err := row.Scan(&g.ID, &g.Name, &g.CreatedAt)
	if err != nil {
		if isUniqueViolation(err) {
			return Genre{}, ErrNameTaken
		}
		return Genre{}, err
	}
	return g, nil
}

func (r *postgresRepository) List(ctx context.Context) ([]Genre, error) {
	query := `SELECT id, name, created_at FROM genres ORDER BY name ASC`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var genres []Genre
	for rows.Next() {
		var g Genre
		if err := rows.Scan(&g.ID, &g.Name, &g.CreatedAt); err != nil {
			return nil, err
		}
		genres = append(genres, g)
	}
	if genres == nil {
		genres = []Genre{}
	}
	return genres, nil
}

func (r *postgresRepository) Delete(ctx context.Context, id string) error {
	_, err := r.db.Exec(ctx, `DELETE FROM genres WHERE id = $1`, id)
	return err
}

func isUniqueViolation(err error) bool {
	return err != nil && (contains(err.Error(), "duplicate key") || contains(err.Error(), "unique constraint"))
}

func contains(s, substr string) bool {
	return len(s) >= len(substr) && (func() bool {
		for i := 0; i+len(substr) <= len(s); i++ {
			if s[i:i+len(substr)] == substr {
				return true
			}
		}
		return false
	})()
}
