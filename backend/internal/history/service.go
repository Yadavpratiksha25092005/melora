package history

import (
	"context"
	"errors"
)

type Service interface {
	Add(ctx context.Context, userID string, req AddHistoryRequest) error
	ListByUser(ctx context.Context, userID string, limit int) ([]HistorySong, error)
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) Add(ctx context.Context, userID string, req AddHistoryRequest) error {
	if req.SongID == "" {
		return errors.New("song_id is required")
	}
	return s.repo.Add(ctx, userID, req.SongID)
}

func (s *service) ListByUser(ctx context.Context, userID string, limit int) ([]HistorySong, error) {
	if limit <= 0 {
		limit = 50
	}
	return s.repo.ListByUser(ctx, userID, limit)
}
