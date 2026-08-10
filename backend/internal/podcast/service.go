package podcast

import (
	"context"
	"errors"
)

type Service interface {
	CreateShow(ctx context.Context, req CreateShowRequest, creatorUserID *string) (ShowResponse, error)
	ListShows(ctx context.Context, limit, offset int) ([]ShowResponse, error)
	ListMyShows(ctx context.Context, creatorUserID string, limit, offset int) ([]ShowResponse, error)
	GetShow(ctx context.Context, id string) (ShowResponse, error)

	CreateEpisode(ctx context.Context, req CreateEpisodeRequest) (EpisodeResponse, error)
	ListEpisodesByShow(ctx context.Context, showID string) ([]EpisodeResponse, error)
	GetEpisode(ctx context.Context, id string) (EpisodeResponse, error)
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) CreateShow(ctx context.Context, req CreateShowRequest, creatorUserID *string) (ShowResponse, error) {
	if req.Title == "" {
		return ShowResponse{}, errors.New("title is required")
	}
	show, err := s.repo.CreateShow(ctx, Show{
		Title: req.Title, HostName: req.HostName,
		Description: req.Description, CoverURL: req.CoverURL,
		CreatorUserID: creatorUserID,
	})
	if err != nil {
		return ShowResponse{}, err
	}
	return ToShowResponse(show), nil
}

func (s *service) ListShows(ctx context.Context, limit, offset int) ([]ShowResponse, error) {
	if limit <= 0 {
		limit = 20
	}
	shows, err := s.repo.ListShows(ctx, limit, offset)
	if err != nil {
		return nil, err
	}
	res := make([]ShowResponse, 0, len(shows))
	for _, sh := range shows {
		res = append(res, ToShowResponse(sh))
	}
	return res, nil
}

func (s *service) ListMyShows(ctx context.Context, creatorUserID string, limit, offset int) ([]ShowResponse, error) {
	shows, err := s.repo.ListShowsByCreator(ctx, creatorUserID, limit, offset)
	if err != nil {
		return nil, err
	}
	res := make([]ShowResponse, 0, len(shows))
	for _, sh := range shows {
		res = append(res, ToShowResponse(sh))
	}
	return res, nil
}

func (s *service) GetShow(ctx context.Context, id string) (ShowResponse, error) {
	show, err := s.repo.GetShow(ctx, id)
	if err != nil {
		return ShowResponse{}, err
	}
	return ToShowResponse(show), nil
}

func (s *service) CreateEpisode(ctx context.Context, req CreateEpisodeRequest) (EpisodeResponse, error) {
	if req.Title == "" {
		return EpisodeResponse{}, errors.New("title is required")
	}
	if req.ShowID == "" {
		return EpisodeResponse{}, errors.New("show_id is required")
	}
	if req.AudioURL == "" && req.VideoURL == "" {
		return EpisodeResponse{}, errors.New("either audio_url or video_url is required")
	}

	ep, err := s.repo.CreateEpisode(ctx, Episode{
		ShowID: req.ShowID, Title: req.Title, Description: req.Description,
		AudioURL: req.AudioURL, VideoURL: req.VideoURL, CoverURL: req.CoverURL,
		DurationMs: req.DurationMs, EpisodeNumber: req.EpisodeNumber,
	})
	if err != nil {
		return EpisodeResponse{}, err
	}
	return ToEpisodeResponse(ep), nil
}

func (s *service) ListEpisodesByShow(ctx context.Context, showID string) ([]EpisodeResponse, error) {
	episodes, err := s.repo.ListEpisodesByShow(ctx, showID)
	if err != nil {
		return nil, err
	}
	res := make([]EpisodeResponse, 0, len(episodes))
	for _, e := range episodes {
		res = append(res, ToEpisodeResponse(e))
	}
	return res, nil
}

func (s *service) GetEpisode(ctx context.Context, id string) (EpisodeResponse, error) {
	ep, err := s.repo.GetEpisode(ctx, id)
	if err != nil {
		return EpisodeResponse{}, err
	}
	return ToEpisodeResponse(ep), nil
}
