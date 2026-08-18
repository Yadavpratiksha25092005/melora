package song

import (
	"context"
	"errors"
	"net/url"
	"strings"
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

// extractS3Key pulls the object key back out of a full stored URL like
// "https://host/{bucket}/{key...}" — GetPresignedURL already prepends
// the bucket itself, so passing it the full URL (instead of just the
// key) doubled the path and produced broken, nested "signed" URLs.
func extractS3Key(rawURL string) string {
	u, err := url.Parse(rawURL)
	if err != nil {
		return rawURL
	}
	path := strings.TrimPrefix(u.Path, "/")
	parts := strings.SplitN(path, "/", 2)
	if len(parts) == 2 {
		return parts[1] // everything after the {bucket}/ segment
	}
	return path
}

// resolveURLs turns stored object keys into temporary, signed URLs the
// browser/app can actually fetch, since the bucket is private.
func (s *service) resolveURLs(ctx context.Context, res *SongResponse) {
	if s.s3Client == nil {
		return
	}
	if res.FileURL != "" {
		key := extractS3Key(res.FileURL)
		if signed, err := s.s3Client.GetPresignedURL(ctx, key, time.Hour); err == nil {
			res.FileURL = signed
		}
	}
	if res.CoverURL != "" {
		key := extractS3Key(res.CoverURL)
		if signed, err := s.s3Client.GetPresignedURL(ctx, key, time.Hour); err == nil {
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
