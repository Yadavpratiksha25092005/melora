package album

import "time"

type Album struct {
	ID         string     `json:"id"`
	ArtistID   string     `json:"artist_id"`
	Title      string     `json:"title"`
	CoverURL   string     `json:"cover_url,omitempty"`
	ReleasedAt *time.Time `json:"released_at,omitempty"`
	CreatedAt  time.Time  `json:"created_at"`
}
