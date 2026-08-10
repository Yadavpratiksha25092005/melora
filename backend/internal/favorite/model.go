package favorite

import "time"

type Favorite struct {
	UserID    string    `json:"user_id"`
	SongID    string    `json:"song_id"`
	CreatedAt time.Time `json:"created_at"`
}

// FavoriteSong is a song row returned when listing a user's favorites.
type FavoriteSong struct {
	ID         string  `json:"id"`
	AlbumID    *string `json:"album_id,omitempty"`
	ArtistID   string  `json:"artist_id"`
	Title      string  `json:"title"`
	DurationMs int     `json:"duration_ms"`
	FileURL    string  `json:"file_url"`
	CoverURL   string  `json:"cover_url,omitempty"`
	Genre      string  `json:"genre,omitempty"`
}
