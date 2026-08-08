package auth

import (
	"context"
	"crypto/rand"
	"errors"
	"fmt"
	"regexp"
	"time"

	"spotify-clone-backend/pkg/jwt"
)

var phoneRegex = regexp.MustCompile(`^\+?[0-9]{10,15}$`)

const (
	tokenTTL = 7 * 24 * time.Hour
	otpTTL   = 5 * time.Minute
	devOTP   = "123456" // used automatically in non-production so you don't need a real SMS gateway yet
)

type Service interface {
	SendOTP(ctx context.Context, req SendOTPRequest) error
	VerifyOTP(ctx context.Context, req VerifyOTPRequest) (VerifyOTPResponse, error)
	Profile(ctx context.Context, userID string) (UserResponse, error)
	UpdateName(ctx context.Context, userID string, name string) (UserResponse, error)
}

type service struct {
	repo      Repository
	jwtSecret string
	isDev     bool
}

func NewService(repo Repository, jwtSecret string, isDev bool) Service {
	return &service{repo: repo, jwtSecret: jwtSecret, isDev: isDev}
}

func generateOTP() (string, error) {
	digits := make([]byte, 6)
	for i := range digits {
		n, err := rand.Int(rand.Reader, bigTen)
		if err != nil {
			return "", err
		}
		digits[i] = byte('0' + n.Int64())
	}
	return string(digits), nil
}

func (s *service) SendOTP(ctx context.Context, req SendOTPRequest) error {
	if !phoneRegex.MatchString(req.Phone) {
		return errors.New("a valid phone number is required")
	}

	otp := devOTP
	if !s.isDev {
		generated, err := generateOTP()
		if err != nil {
			return err
		}
		otp = generated
	}

	// make sure the user row exists so we have somewhere to store the OTP
	_, err := s.repo.GetByPhoneNumber(ctx, req.Phone)
	if errors.Is(err, ErrUserNotFound) {
		if _, err := s.repo.CreateWithPhone(ctx, req.Phone); err != nil {
			return err
		}
	} else if err != nil {
		return err
	}

	if err := s.repo.SetOTP(ctx, req.Phone, otp, time.Now().Add(otpTTL)); err != nil {
		return err
	}

	// TODO: plug in a real SMS gateway (Twilio, MSG91, etc.) here.
	// For now the OTP is fixed to devOTP in dev mode so you can test end-to-end.
	fmt.Printf("[DEV] OTP for %s is %s\n", req.Phone, otp)
	return nil
}

func (s *service) VerifyOTP(ctx context.Context, req VerifyOTPRequest) (VerifyOTPResponse, error) {
	user, err := s.repo.GetByPhoneNumber(ctx, req.Phone)
	if err != nil {
		return VerifyOTPResponse{}, errors.New("invalid phone number or otp")
	}

	if user.OTPCode == "" || user.OTPCode != req.OTP {
		return VerifyOTPResponse{}, errors.New("invalid phone number or otp")
	}
	if user.OTPExpires == nil || time.Now().After(*user.OTPExpires) {
		return VerifyOTPResponse{}, errors.New("otp has expired, please request a new one")
	}

	_ = s.repo.ClearOTP(ctx, user.ID)

	token, err := jwt.GenerateToken(s.jwtSecret, user.ID, user.PhoneNumber, tokenTTL)
	if err != nil {
		return VerifyOTPResponse{}, err
	}

	return VerifyOTPResponse{
		Token: token,
		User:  ToUserResponse(user),
	}, nil
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
