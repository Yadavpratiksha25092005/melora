package playlist

import "time"

type Playlist struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Name      string    `json:"name"`
	CoverURL  string    `json:"cover_url,omitempty"`
	IsPublic  bool      `json:"is_public"`
	CreatedAt time.Time `json:"created_at"`
}

// PlaylistSong mirrors one row from songs, joined via playlist_songs.
type PlaylistSong struct {
	ID         string  `json:"id"`
	AlbumID    *string `json:"album_id,omitempty"`
	ArtistID   string  `json:"artist_id"`
	Title      string  `json:"title"`
	DurationMs int     `json:"duration_ms"`
	FileURL    string  `json:"file_url"`
	CoverURL   string  `json:"cover_url,omitempty"`
	Genre      string  `json:"genre,omitempty"`
}
