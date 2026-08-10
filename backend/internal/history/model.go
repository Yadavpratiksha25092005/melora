package history

import "time"

type HistoryEntry struct {
	ID       string    `json:"id"`
	UserID   string    `json:"user_id"`
	SongID   string    `json:"song_id"`
	PlayedAt time.Time `json:"played_at"`
}

// HistorySong is a song row returned when listing a user's recently played songs.
type HistorySong struct {
	ID         string  `json:"id"`
	AlbumID    *string `json:"album_id,omitempty"`
	ArtistID   string  `json:"artist_id"`
	Title      string  `json:"title"`
	DurationMs int     `json:"duration_ms"`
	FileURL    string  `json:"file_url"`
	CoverURL   string  `json:"cover_url,omitempty"`
	Genre      string  `json:"genre,omitempty"`
	PlayedAt   string  `json:"played_at"`
}
