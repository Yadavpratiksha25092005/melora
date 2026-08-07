package artist

import (
	"context"
	"errors"
)

type Service interface {
	Create(ctx context.Context, req CreateArtistRequest, ownerUserID *string) (ArtistResponse, error)
	Get(ctx context.Context, id string) (ArtistResponse, error)
	GetMine(ctx context.Context, ownerUserID string) (ArtistResponse, error)
	List(ctx context.Context, limit, offset int) ([]ArtistResponse, error)
	Update(ctx context.Context, id string, req UpdateArtistRequest) (ArtistResponse, error)
	Delete(ctx context.Context, id string) error
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) Create(ctx context.Context, req CreateArtistRequest, ownerUserID *string) (ArtistResponse, error) {
	if req.Name == "" {
		return ArtistResponse{}, errors.New("name is required")
	}
	a, err := s.repo.Create(ctx, req.Name, req.Bio, req.ImageURL, ownerUserID)
	if err != nil {
		return ArtistResponse{}, err
	}
	return ToResponse(a), nil
}

func (s *service) Get(ctx context.Context, id string) (ArtistResponse, error) {
	a, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return ArtistResponse{}, err
	}
	return ToResponse(a), nil
}

func (s *service) GetMine(ctx context.Context, ownerUserID string) (ArtistResponse, error) {
	a, err := s.repo.GetByOwner(ctx, ownerUserID)
	if err != nil {
		return ArtistResponse{}, err
	}
	return ToResponse(a), nil
}

func (s *service) List(ctx context.Context, limit, offset int) ([]ArtistResponse, error) {
	if limit <= 0 {
		limit = 20
	}
	artists, err := s.repo.List(ctx, limit, offset)
	if err != nil {
		return nil, err
	}
	res := make([]ArtistResponse, 0, len(artists))
	for _, a := range artists {
		res = append(res, ToResponse(a))
	}
	return res, nil
}

func (s *service) Update(ctx context.Context, id string, req UpdateArtistRequest) (ArtistResponse, error) {
	if req.Name == "" {
		return ArtistResponse{}, errors.New("name is required")
	}
	a, err := s.repo.Update(ctx, id, req.Name, req.Bio, req.ImageURL)
	if err != nil {
		return ArtistResponse{}, err
	}
	return ToResponse(a), nil
}

func (s *service) Delete(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}
