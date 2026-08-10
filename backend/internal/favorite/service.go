package favorite

import (
	"context"
	"errors"
)

type Service interface {
	Add(ctx context.Context, userID string, req AddFavoriteRequest) error
	Remove(ctx context.Context, userID, songID string) error
	ListByUser(ctx context.Context, userID string) ([]FavoriteSong, error)
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) Add(ctx context.Context, userID string, req AddFavoriteRequest) error {
	if req.SongID == "" {
		return errors.New("song_id is required")
	}
	return s.repo.Add(ctx, userID, req.SongID)
}

func (s *service) Remove(ctx context.Context, userID, songID string) error {
	return s.repo.Remove(ctx, userID, songID)
}

func (s *service) ListByUser(ctx context.Context, userID string) ([]FavoriteSong, error) {
	return s.repo.ListByUser(ctx, userID)
}
