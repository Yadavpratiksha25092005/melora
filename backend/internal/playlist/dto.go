package playlist

type CreatePlaylistRequest struct {
	Name     string `json:"name"`
	CoverURL string `json:"cover_url"`
	IsPublic bool   `json:"is_public"`
}

type AddSongRequest struct {
	SongID string `json:"song_id"`
}

type PlaylistResponse struct {
	ID       string         `json:"id"`
	UserID   string         `json:"user_id"`
	Name     string         `json:"name"`
	CoverURL string         `json:"cover_url,omitempty"`
	IsPublic bool           `json:"is_public"`
	Songs    []PlaylistSong `json:"songs"`
}

func ToResponse(p Playlist, songs []PlaylistSong) PlaylistResponse {
	if songs == nil {
		songs = []PlaylistSong{}
	}
	return PlaylistResponse{
		ID:       p.ID,
		UserID:   p.UserID,
		Name:     p.Name,
		CoverURL: p.CoverURL,
		IsPublic: p.IsPublic,
		Songs:    songs,
	}
}
