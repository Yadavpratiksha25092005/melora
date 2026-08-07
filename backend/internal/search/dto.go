package search

type SearchResponse struct {
	Songs   []SongResult   `json:"songs"`
	Artists []ArtistResult `json:"artists"`
	Albums  []AlbumResult  `json:"albums"`
}

type SongResult struct {
	ID       string `json:"id"`
	Title    string `json:"title"`
	ArtistID string `json:"artist_id"`
	CoverURL string `json:"cover_url,omitempty"`
}

type ArtistResult struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	ImageURL string `json:"image_url,omitempty"`
}

type AlbumResult struct {
	ID       string `json:"id"`
	Title    string `json:"title"`
	ArtistID string `json:"artist_id"`
	CoverURL string `json:"cover_url,omitempty"`
}
