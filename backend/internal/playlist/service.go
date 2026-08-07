package playlist

import (
	"context"
	"errors"
)

type Service interface {
	Create(ctx context.Context, userID string, req CreatePlaylistRequest) (PlaylistResponse, error)
	Get(ctx context.Context, id string) (PlaylistResponse, error)
	ListByUser(ctx context.Context, userID string, limit, offset int) ([]PlaylistResponse, error)
	Delete(ctx context.Context, id string) error
	AddSong(ctx context.Context, playlistID string, req AddSongRequest) error
	RemoveSong(ctx context.Context, playlistID, songID string) error
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) Create(ctx context.Context, userID string, req CreatePlaylistRequest) (PlaylistResponse, error) {
	if req.Name == "" {
		return PlaylistResponse{}, errors.New("name is required")
	}
	p, err := s.repo.Create(ctx, userID, req.Name, req.CoverURL, req.IsPublic)
	if err != nil {
		return PlaylistResponse{}, err
	}
	return ToResponse(p, nil), nil
}

func (s *service) Get(ctx context.Context, id string) (PlaylistResponse, error) {
	p, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return PlaylistResponse{}, err
	}
	songs, err := s.repo.SongsForPlaylist(ctx, id)
	if err != nil {
		return PlaylistResponse{}, err
	}
	return ToResponse(p, songs), nil
}

func (s *service) ListByUser(ctx context.Context, userID string, limit, offset int) ([]PlaylistResponse, error) {
	if limit <= 0 {
		limit = 20
	}
	playlists, err := s.repo.ListByUser(ctx, userID, limit, offset)
	if err != nil {
		return nil, err
	}
	res := make([]PlaylistResponse, 0, len(playlists))
	for _, p := range playlists {
		songs, err := s.repo.SongsForPlaylist(ctx, p.ID)
		if err != nil {
			return nil, err
		}
		res = append(res, ToResponse(p, songs))
	}
	return res, nil
}

func (s *service) Delete(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}

func (s *service) AddSong(ctx context.Context, playlistID string, req AddSongRequest) error {
	if req.SongID == "" {
		return errors.New("song_id is required")
	}
	return s.repo.AddSong(ctx, playlistID, req.SongID)
}

func (s *service) RemoveSong(ctx context.Context, playlistID, songID string) error {
	return s.repo.RemoveSong(ctx, playlistID, songID)
}
