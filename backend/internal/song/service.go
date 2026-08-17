package song

import (
	"context"
	"errors"
	"time"

	"spotify-clone-backend/pkg/s3"
)

type Service interface {
	Create(ctx context.Context, req CreateSongRequest) (SongResponse, error)
	Get(ctx context.Context, id string) (SongResponse, error)
	List(ctx context.Context, limit, offset int) ([]SongResponse, error)
	ListMine(ctx context.Context, artistID string, limit, offset int) ([]SongResponse, error)
	Delete(ctx context.Context, id string) error
}

type service struct {
	repo     Repository
	s3Client *s3.Client
}

func NewService(repo Repository, s3Client *s3.Client) Service {
	return &service{repo: repo, s3Client: s3Client}
}

// resolveURLs turns stored object keys into temporary, signed URLs the
// browser/app can actually fetch, since the bucket is private.
func (s *service) resolveURLs(ctx context.Context, res *SongResponse) {
	if s.s3Client == nil {
		return
	}
	if res.FileURL != "" {
		if signed, err := s.s3Client.GetPresignedURL(ctx, res.FileURL, time.Hour); err == nil {
			res.FileURL = signed
		}
	}
	if res.CoverURL != "" {
		if signed, err := s.s3Client.GetPresignedURL(ctx, res.CoverURL, time.Hour); err == nil {
			res.CoverURL = signed
		}
	}
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
	res := ToResponse(created)
	s.resolveURLs(ctx, &res)
	return res, nil
}

func (s *service) Get(ctx context.Context, id string) (SongResponse, error) {
	sng, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return SongResponse{}, err
	}
	res := ToResponse(sng)
	s.resolveURLs(ctx, &res)
	return res, nil
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
		r := ToResponse(sng)
		s.resolveURLs(ctx, &r)
		res = append(res, r)
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
		r := ToResponse(sng)
		s.resolveURLs(ctx, &r)
		res = append(res, r)
	}
	return res, nil
}
