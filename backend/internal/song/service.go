package song

import (
	"context"
	"errors"
)

type Service interface {
	Create(ctx context.Context, req CreateSongRequest) (SongResponse, error)
	Get(ctx context.Context, id string) (SongResponse, error)
	List(ctx context.Context, limit, offset int) ([]SongResponse, error)
	ListMine(ctx context.Context, artistID string, limit, offset int) ([]SongResponse, error)
	Delete(ctx context.Context, id string) error
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) Create(ctx context.Context, req CreateSongRequest) (SongResponse, error) {
	if req.Title == "" {
		return SongResponse{}, errors.New("title is required")
	}
	if req.ArtistID == "" {
		return SongResponse{}, errors.New("artist_id is required")
	}

	created, err := s.repo.Create(ctx, Song{
		AlbumID:    req.AlbumID,
		ArtistID:   req.ArtistID,
		Title:      req.Title,
		DurationMs: req.DurationMs,
		FileURL:    req.FileURL,
		CoverURL:   req.CoverURL,
		Genre:      req.Genre,
		Language:   req.Language,
		Lyrics:     req.Lyrics,
	})
	if err != nil {
		return SongResponse{}, err
	}
	return ToResponse(created), nil
}

func (s *service) Get(ctx context.Context, id string) (SongResponse, error) {
	sng, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return SongResponse{}, err
	}
	return ToResponse(sng), nil
}

func (s *service) List(ctx context.Context, limit, offset int) ([]SongResponse, error) {
	if limit <= 0 {
		limit = 20
	}
	songs, err := s.repo.List(ctx, limit, offset)
	if err != nil {
		return nil, err
	}
	res := make([]SongResponse, 0, len(songs))
	for _, sng := range songs {
		res = append(res, ToResponse(sng))
	}
	return res, nil
}

func (s *service) Delete(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}
func (s *service) ListMine(ctx context.Context, artistID string, limit, offset int) ([]SongResponse, error) {
	songs, err := s.repo.ListByArtist(ctx, artistID, limit, offset)
	if err != nil {
		return nil, err
	}
	res := make([]SongResponse, 0, len(songs))
	for _, sng := range songs {
		res = append(res, ToResponse(sng))
	}
	return res, nil
}
