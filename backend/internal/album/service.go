package album

import (
	"context"
	"errors"
	"time"
)

type Service interface {
	Create(ctx context.Context, req CreateAlbumRequest) (AlbumResponse, error)
	Get(ctx context.Context, id string) (AlbumResponse, error)
	List(ctx context.Context, limit, offset int) ([]AlbumResponse, error)
	Update(ctx context.Context, id string, req UpdateAlbumRequest) (AlbumResponse, error)
	Delete(ctx context.Context, id string) error
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func parseDate(s string) *time.Time {
	if s == "" {
		return nil
	}
	t, err := time.Parse("2006-01-02", s)
	if err != nil {
		return nil
	}
	return &t
}

func (s *service) Create(ctx context.Context, req CreateAlbumRequest) (AlbumResponse, error) {
	if req.Title == "" {
		return AlbumResponse{}, errors.New("title is required")
	}
	if req.ArtistID == "" {
		return AlbumResponse{}, errors.New("artist_id is required")
	}

	a, err := s.repo.Create(ctx, req.ArtistID, req.Title, req.CoverURL, parseDate(req.ReleasedAt))
	if err != nil {
		return AlbumResponse{}, err
	}
	return ToResponse(a), nil
}

func (s *service) Get(ctx context.Context, id string) (AlbumResponse, error) {
	a, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return AlbumResponse{}, err
	}
	return ToResponse(a), nil
}

func (s *service) List(ctx context.Context, limit, offset int) ([]AlbumResponse, error) {
	if limit <= 0 {
		limit = 20
	}
	albums, err := s.repo.List(ctx, limit, offset)
	if err != nil {
		return nil, err
	}
	res := make([]AlbumResponse, 0, len(albums))
	for _, a := range albums {
		res = append(res, ToResponse(a))
	}
	return res, nil
}

func (s *service) Update(ctx context.Context, id string, req UpdateAlbumRequest) (AlbumResponse, error) {
	if req.Title == "" {
		return AlbumResponse{}, errors.New("title is required")
	}
	a, err := s.repo.Update(ctx, id, req.Title, req.CoverURL, parseDate(req.ReleasedAt))
	if err != nil {
		return AlbumResponse{}, err
	}
	return ToResponse(a), nil
}

func (s *service) Delete(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}
