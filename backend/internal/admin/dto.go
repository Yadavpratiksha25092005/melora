package admin

type DashboardResponse struct {
	TotalUsers   int `json:"total_users"`
	TotalSongs   int `json:"total_songs"`
	TotalArtists int `json:"total_artists"`
	TotalAlbums  int `json:"total_albums"`
	PendingSongs int `json:"pending_songs"`
}

type UserResponse struct {
	ID          string `json:"id"`
	Name        string `json:"name,omitempty"`
	PhoneNumber string `json:"phone_number"`
	IsAdmin     bool   `json:"is_admin"`
}
