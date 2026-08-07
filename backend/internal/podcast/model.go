package podcast

import "time"

type Show struct {
	ID            string    `json:"id"`
	Title         string    `json:"title"`
	HostName      string    `json:"host_name,omitempty"`
	Description   string    `json:"description,omitempty"`
	CoverURL      string    `json:"cover_url,omitempty"`
	CreatorUserID *string   `json:"creator_user_id,omitempty"`
	CreatedAt     time.Time `json:"created_at"`
}

type Episode struct {
	ID            string    `json:"id"`
	ShowID        string    `json:"show_id"`
	Title         string    `json:"title"`
	Description   string    `json:"description,omitempty"`
	AudioURL      string    `json:"audio_url,omitempty"`
	VideoURL      string    `json:"video_url,omitempty"`
	CoverURL      string    `json:"cover_url,omitempty"`
	DurationMs    int       `json:"duration_ms,omitempty"`
	EpisodeNumber int       `json:"episode_number,omitempty"`
	CreatedAt     time.Time `json:"created_at"`
}
