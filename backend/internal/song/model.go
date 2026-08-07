package song

import "time"

type Song struct {
	ID         string    `json:"id"`
	AlbumID    *string   `json:"album_id,omitempty"`
	ArtistID   string    `json:"artist_id"`
	ArtistName string    `json:"artist_name,omitempty"`
	Title      string    `json:"title"`
	DurationMs int       `json:"duration_ms"`
	FileURL    string    `json:"file_url"`
	CoverURL   string    `json:"cover_url"`
	Genre      string    `json:"genre"`
	Language   string    `json:"language"`
	Lyrics     string    `json:"lyrics"`
	Status     string    `json:"status"`
	PlayCount  int       `json:"play_count"`
	CreatedAt  time.Time `json:"created_at"`
}
