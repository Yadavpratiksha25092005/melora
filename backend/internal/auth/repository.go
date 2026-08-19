package auth

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrUserNotFound = errors.New("user not found")
var ErrEmailTaken = errors.New("email already registered")

type Repository interface {
	GetByEmail(ctx context.Context, email string) (User, error)
	CreateWithEmail(ctx context.Context, name, email, passwordHash string) (User, error)
	UpdatePasswordByEmail(ctx context.Context, email, passwordHash string) error
	GetByID(ctx context.Context, id string) (User, error)
	UpdateName(ctx context.Context, id string, name string) (User, error)
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

const userColumns = `id, COALESCE(name, ''), COALESCE(email, ''), COALESCE(password_hash, ''), COALESCE(phone_number, ''), is_admin, created_at`

func scanUser(row pgx.Row) (User, error) {
	var u User
	err := row.Scan(&u.ID, &u.Name, &u.Email, &u.PasswordHash, &u.PhoneNumber, &u.IsAdmin, &u.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return User{}, ErrUserNotFound
	}
	return u, err
}

func (r *postgresRepository) GetByEmail(ctx context.Context, email string) (User, error) {
	query := `SELECT ` + userColumns + ` FROM users WHERE email = $1`
	return scanUser(r.db.QueryRow(ctx, query, email))
}

func (r *postgresRepository) GetByID(ctx context.Context, id string) (User, error) {
	query := `SELECT ` + userColumns + ` FROM users WHERE id = $1`
	return scanUser(r.db.QueryRow(ctx, query, id))
}

func (r *postgresRepository) CreateWithEmail(ctx context.Context, name, email, passwordHash string) (User, error) {
	query := `INSERT INTO users (name, email, password_hash) VALUES ($1, $2, $3) RETURNING ` + userColumns
	user, err := scanUser(r.db.QueryRow(ctx, query, name, email, passwordHash))
	if err != nil {
		var pgErr interface{ SQLState() string }
		if errors.As(err, &pgErr) && pgErr.SQLState() == "23505" {
			return User{}, ErrEmailTaken
		}
	}
	return user, err
}

func (r *postgresRepository) UpdatePasswordByEmail(ctx context.Context, email, passwordHash string) error {
	tag, err := r.db.Exec(ctx, `UPDATE users SET password_hash = $2 WHERE email = $1`, email, passwordHash)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrUserNotFound
	}
	return nil
}

func (r *postgresRepository) UpdateName(ctx context.Context, id string, name string) (User, error) {
	query := `UPDATE users SET name = $2 WHERE id = $1 RETURNING ` + userColumns
	return scanUser(r.db.QueryRow(ctx, query, id, name))
}
