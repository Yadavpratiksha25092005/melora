package auth

import (
	"context"
	"errors"
	"regexp"
	"time"

	"golang.org/x/crypto/bcrypt"

	"spotify-clone-backend/pkg/jwt"
)

var emailRegex = regexp.MustCompile(`^[^\s@]+@[^\s@]+\.[^\s@]+$`)

const tokenTTL = 7 * 24 * time.Hour

type Service interface {
	Signup(ctx context.Context, req SignupRequest) (AuthResponse, error)
	Login(ctx context.Context, req LoginRequest) (AuthResponse, error)
	ForgotPassword(ctx context.Context, req ForgotPasswordRequest) error
	Profile(ctx context.Context, userID string) (UserResponse, error)
	UpdateName(ctx context.Context, userID string, name string) (UserResponse, error)
}

type service struct {
	repo      Repository
	jwtSecret string
}

func NewService(repo Repository, jwtSecret string) Service {
	return &service{repo: repo, jwtSecret: jwtSecret}
}

func (s *service) Signup(ctx context.Context, req SignupRequest) (AuthResponse, error) {
	if !emailRegex.MatchString(req.Email) {
		return AuthResponse{}, errors.New("invalid email address")
	}
	if len(req.Password) < 6 {
		return AuthResponse{}, errors.New("password must be at least 6 characters")
	}
	if len(req.Name) == 0 {
		return AuthResponse{}, errors.New("name is required")
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return AuthResponse{}, err
	}

	user, err := s.repo.CreateWithEmail(ctx, req.Name, req.Email, string(hash))
	if err != nil {
		if errors.Is(err, ErrEmailTaken) {
			return AuthResponse{}, errors.New("an account with this email already exists")
		}
		return AuthResponse{}, err
	}

	token, err := jwt.GenerateToken(s.jwtSecret, user.ID, user.Email, tokenTTL)
	if err != nil {
		return AuthResponse{}, err
	}

	return AuthResponse{Token: token, User: ToUserResponse(user)}, nil
}

func (s *service) Login(ctx context.Context, req LoginRequest) (AuthResponse, error) {
	user, err := s.repo.GetByEmail(ctx, req.Email)
	if err != nil {
		return AuthResponse{}, errors.New("invalid email or password")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return AuthResponse{}, errors.New("invalid email or password")
	}

	token, err := jwt.GenerateToken(s.jwtSecret, user.ID, user.Email, tokenTTL)
	if err != nil {
		return AuthResponse{}, err
	}

	return AuthResponse{Token: token, User: ToUserResponse(user)}, nil
}

// ForgotPassword — simple flow with no email verification step: if an
// account exists with this email, its password is updated directly to
// the new password supplied. (No reset code / email confirmation.)
func (s *service) ForgotPassword(ctx context.Context, req ForgotPasswordRequest) error {
	if len(req.NewPassword) < 6 {
		return errors.New("password must be at least 6 characters")
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	if err := s.repo.UpdatePasswordByEmail(ctx, req.Email, string(hash)); err != nil {
		if errors.Is(err, ErrUserNotFound) {
			return errors.New("no account found with this email")
		}
		return err
	}
	return nil
}

func (s *service) Profile(ctx context.Context, userID string) (UserResponse, error) {
	user, err := s.repo.GetByID(ctx, userID)
	if err != nil {
		return UserResponse{}, err
	}
	return ToUserResponse(user), nil
}

func (s *service) UpdateName(ctx context.Context, userID string, name string) (UserResponse, error) {
	if len(name) == 0 {
		return UserResponse{}, errors.New("name is required")
	}
	user, err := s.repo.UpdateName(ctx, userID, name)
	if err != nil {
		return UserResponse{}, err
	}
	return ToUserResponse(user), nil
}
