package album

type CreateAlbumRequest struct {
	ArtistID   string `json:"artist_id"`
	Title      string `json:"title"`
	CoverURL   string `json:"cover_url"`
	ReleasedAt string `json:"released_at"` // format: "2024-01-15"
}

type UpdateAlbumRequest struct {
	Title      string `json:"title"`
	CoverURL   string `json:"cover_url"`
	ReleasedAt string `json:"released_at"`
}

type AlbumResponse struct {
	ID         string `json:"id"`
	ArtistID   string `json:"artist_id"`
	Title      string `json:"title"`
	CoverURL   string `json:"cover_url,omitempty"`
	ReleasedAt string `json:"released_at,omitempty"`
}

func ToResponse(a Album) AlbumResponse {
	releasedAt := ""
	if a.ReleasedAt != nil {
		releasedAt = a.ReleasedAt.Format("2006-01-02")
	}
	return AlbumResponse{
		ID:         a.ID,
		ArtistID:   a.ArtistID,
		Title:      a.Title,
		CoverURL:   a.CoverURL,
		ReleasedAt: releasedAt,
	}
}
