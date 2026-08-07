package distributor

import (
	"context"
	"errors"
	"strings"
)

const (
	StatusPublished   = "PUBLISHED"
	StatusUnderReview = "UNDER_REVIEW"
	StatusRejected    = "REJECTED"
)

type Service interface {
	UploadSong(ctx context.Context, req UploadSongRequest) (UploadSongResponse, error)
	ListPending(ctx context.Context) ([]PendingSongResponse, error)
	Approve(ctx context.Context, songID string) error
	Reject(ctx context.Context, songID string) error
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

// validate runs the automatic checks. Returns a non-empty reason if
// something looks off — in that case the song goes to UNDER_REVIEW
// instead of being published immediately.
func (s *service) validate(ctx context.Context, req UploadSongRequest) (string, error) {
	if strings.TrimSpace(req.Title) == "" {
		return "", errors.New("title is required")
	}
	if req.ArtistID == "" {
		return "", errors.New("artist_id is required")
	}
	if strings.TrimSpace(req.FileURL) == "" {
		return "", errors.New("file_url is required")
	}

	// duplicate check — same artist uploading the same title again
	dupCount, err := s.repo.CountDuplicates(ctx, req.ArtistID, req.Title)
	if err != nil {
		return "", err
	}
	if dupCount > 0 {
		return "possible duplicate: this artist already has a song with this title", nil
	}

	// duration sanity check — flag anything absurdly short or long
	if req.DurationMs > 0 && (req.DurationMs < 10000 || req.DurationMs > 1800000) {
		return "unusual duration — please verify the audio file", nil
	}

	// file URL sanity check — must look like an audio file
	lower := strings.ToLower(req.FileURL)
	if !strings.HasSuffix(lower, ".mp3") && !strings.HasSuffix(lower, ".wav") && !strings.HasSuffix(lower, ".m4a") {
		return "file does not look like a supported audio format", nil
	}

	return "", nil // all checks passed
}

func (s *service) UploadSong(ctx context.Context, req UploadSongRequest) (UploadSongResponse, error) {
	reason, err := s.validate(ctx, req)
	if err != nil {
		// hard failure — reject the request outright, nothing is saved
		return UploadSongResponse{}, err
	}

	status := StatusPublished
	if reason != "" {
		status = StatusUnderReview
	}

	var albumID *string
	if req.AlbumID != "" {
		albumID = &req.AlbumID
	}

	id, err := s.repo.Insert(ctx, Song{
		ArtistID:   req.ArtistID,
		AlbumID:    albumID,
		Title:      req.Title,
		DurationMs: req.DurationMs,
		FileURL:    req.FileURL,
		CoverURL:   req.CoverURL,
		Genre:      req.Genre,
		Status:     status,
	})
	if err != nil {
		return UploadSongResponse{}, err
	}

	return UploadSongResponse{
		ID:     id,
		Title:  req.Title,
		Status: status,
		Reason: reason,
	}, nil
}

func (s *service) ListPending(ctx context.Context) ([]PendingSongResponse, error) {
	return s.repo.ListByStatus(ctx, StatusUnderReview)
}

func (s *service) Approve(ctx context.Context, songID string) error {
	return s.repo.UpdateStatus(ctx, songID, StatusPublished)
}

func (s *service) Reject(ctx context.Context, songID string) error {
	return s.repo.UpdateStatus(ctx, songID, StatusRejected)
}
