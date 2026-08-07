package user

import (
	"context"
	"errors"
)

type Service interface {
	UpdateProfile(ctx context.Context, userID string, req UpdateProfileRequest) (UserResponse, error)
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) UpdateProfile(ctx context.Context, userID string, req UpdateProfileRequest) (UserResponse, error) {
	if req.Name == "" {
		return UserResponse{}, errors.New("name is required")
	}
	return s.repo.UpdateProfile(ctx, userID, req.Name, req.AvatarURL)
}
