package genre

import (
	"context"
	"errors"
)

type Service interface {
	Create(ctx context.Context, req CreateGenreRequest) (GenreResponse, error)
	List(ctx context.Context) ([]GenreResponse, error)
	Delete(ctx context.Context, id string) error
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) Create(ctx context.Context, req CreateGenreRequest) (GenreResponse, error) {
	if req.Name == "" {
		return GenreResponse{}, errors.New("name is required")
	}
	g, err := s.repo.Create(ctx, req.Name)
	if err != nil {
		return GenreResponse{}, err
	}
	return ToResponse(g), nil
}

func (s *service) List(ctx context.Context) ([]GenreResponse, error) {
	genres, err := s.repo.List(ctx)
	if err != nil {
		return nil, err
	}
	res := make([]GenreResponse, 0, len(genres))
	for _, g := range genres {
		res = append(res, ToResponse(g))
	}
	return res, nil
}

func (s *service) Delete(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}
