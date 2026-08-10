package song

type CreateSongRequest struct {
	AlbumID    *string `json:"album_id"`
	ArtistID   string  `json:"artist_id"`
	Title      string  `json:"title"`
	DurationMs int     `json:"duration_ms"`
	FileURL    string  `json:"file_url"`
	CoverURL   string  `json:"cover_url"`
	Genre      string  `json:"genre"`
	Language   string  `json:"language"`
	Lyrics     string  `json:"lyrics"`
}

type SongResponse struct {
	ID         string  `json:"id"`
	AlbumID    *string `json:"album_id,omitempty"`
	ArtistID   string  `json:"artist_id"`
	ArtistName string  `json:"artist_name,omitempty"`
	Title      string  `json:"title"`
	DurationMs int     `json:"duration_ms"`
	FileURL    string  `json:"file_url"`
	CoverURL   string  `json:"cover_url"`
	Genre      string  `json:"genre"`
	Language   string  `json:"language"`
	Lyrics     string  `json:"lyrics"`
	Status     string  `json:"status"`
	PlayCount  int     `json:"play_count"`
}

func ToResponse(s Song) SongResponse {
	return SongResponse{
		ID:         s.ID,
		AlbumID:    s.AlbumID,
		ArtistID:   s.ArtistID,
		ArtistName: s.ArtistName,
		Title:      s.Title,
		DurationMs: s.DurationMs,
		FileURL:    s.FileURL,
		CoverURL:   s.CoverURL,
		Genre:      s.Genre,
		Language:   s.Language,
		Lyrics:     s.Lyrics,
		Status:     s.Status,
		PlayCount:  s.PlayCount,
	}
}
