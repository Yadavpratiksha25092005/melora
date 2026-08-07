package search

import "context"

type Service interface {
	Search(ctx context.Context, query string) (SearchResponse, error)
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) Search(ctx context.Context, query string) (SearchResponse, error) {
	if query == "" {
		return SearchResponse{
			Songs:   []SongResult{},
			Artists: []ArtistResult{},
			Albums:  []AlbumResult{},
		}, nil
	}

	songs, err := s.repo.SearchSongs(ctx, query, 20)
	if err != nil {
		return SearchResponse{}, err
	}
	artists, err := s.repo.SearchArtists(ctx, query, 20)
	if err != nil {
		return SearchResponse{}, err
	}
	albums, err := s.repo.SearchAlbums(ctx, query, 20)
	if err != nil {
		return SearchResponse{}, err
	}

	return SearchResponse{Songs: songs, Artists: artists, Albums: albums}, nil
}
