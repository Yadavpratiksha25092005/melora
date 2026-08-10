package distributor

type UploadSongRequest struct {
	ArtistID   string `json:"artist_id"`
	AlbumID    string `json:"album_id"`
	Title      string `json:"title"`
	DurationMs int    `json:"duration_ms"`
	FileURL    string `json:"file_url"`
	CoverURL   string `json:"cover_url"`
	Genre      string `json:"genre"`
}

type UploadSongResponse struct {
	ID     string `json:"id"`
	Title  string `json:"title"`
	Status string `json:"status"`
	Reason string `json:"reason,omitempty"` // why it was flagged, if it was
}

type PendingSongResponse struct {
	ID         string `json:"id"`
	Title      string `json:"title"`
	ArtistID   string `json:"artist_id"`
	Status     string `json:"status"`
	FlagReason string `json:"flag_reason,omitempty"`
}
