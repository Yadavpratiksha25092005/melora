package auth

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrUserNotFound = errors.New("user not found")

type Repository interface {
	GetByPhoneNumber(ctx context.Context, phoneNumber string) (User, error)
	CreateWithPhone(ctx context.Context, phoneNumber string) (User, error)
	SetOTP(ctx context.Context, phoneNumber, otp string, expiresAt time.Time) error
	GetByID(ctx context.Context, id string) (User, error)
	ClearOTP(ctx context.Context, id string) error
	UpdateName(ctx context.Context, id string, name string) (User, error)
}

type postgresRepository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) GetByPhoneNumber(ctx context.Context, phoneNumber string) (User, error) {
	query := `SELECT id, COALESCE(name, ''), phone_number, is_admin, COALESCE(otp_code, ''), otp_expires_at, created_at FROM users WHERE phone_number = $1`
	row := r.db.QueryRow(ctx, query, phoneNumber)

	var u User
	err := row.Scan(&u.ID, &u.Name, &u.PhoneNumber, &u.IsAdmin, &u.OTPCode, &u.OTPExpires, &u.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return User{}, ErrUserNotFound
	}
	return u, err
}

func (r *postgresRepository) CreateWithPhone(ctx context.Context, phoneNumber string) (User, error) {
	query := `
		INSERT INTO users (phone_number)
		VALUES ($1)
		RETURNING id, COALESCE(name, ''), phone_number, is_admin, COALESCE(otp_code, ''), otp_expires_at, created_at
	`
	row := r.db.QueryRow(ctx, query, phoneNumber)

	var u User
	err := row.Scan(&u.ID, &u.Name, &u.PhoneNumber, &u.IsAdmin, &u.OTPCode, &u.OTPExpires, &u.CreatedAt)
	return u, err
}

func (r *postgresRepository) SetOTP(ctx context.Context, phoneNumber, otp string, expiresAt time.Time) error {
	_, err := r.db.Exec(ctx,
		`UPDATE users SET otp_code = $2, otp_expires_at = $3 WHERE phone_number = $1`,
		phoneNumber, otp, expiresAt,
	)
	return err
}

func (r *postgresRepository) GetByID(ctx context.Context, id string) (User, error) {
	query := `SELECT id, COALESCE(name, ''), phone_number, is_admin, COALESCE(otp_code, ''), otp_expires_at, created_at FROM users WHERE id = $1`
	row := r.db.QueryRow(ctx, query, id)

	var u User
	err := row.Scan(&u.ID, &u.Name, &u.PhoneNumber, &u.IsAdmin, &u.OTPCode, &u.OTPExpires, &u.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return User{}, ErrUserNotFound
	}
	return u, err
}

func (r *postgresRepository) ClearOTP(ctx context.Context, id string) error {
	_, err := r.db.Exec(ctx, `UPDATE users SET otp_code = NULL, otp_expires_at = NULL WHERE id = $1`, id)
	return err
}
func (r *postgresRepository) UpdateName(ctx context.Context, id string, name string) (User, error) {
	query := `UPDATE users SET name = $2 WHERE id = $1 RETURNING id, COALESCE(name, ''), phone_number, is_admin, COALESCE(otp_code, ''), otp_expires_at, created_at`
	row := r.db.QueryRow(ctx, query, id, name)

	var u User
	err := row.Scan(&u.ID, &u.Name, &u.PhoneNumber, &u.IsAdmin, &u.OTPCode, &u.OTPExpires, &u.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return User{}, ErrUserNotFound
	}
	return u, err
}
