package artist

type CreateArtistRequest struct {
	Name     string `json:"name"`
	Bio      string `json:"bio"`
	ImageURL string `json:"image_url"`
}

type UpdateArtistRequest struct {
	Name     string `json:"name"`
	Bio      string `json:"bio"`
	ImageURL string `json:"image_url"`
}

type ArtistResponse struct {
	ID             string `json:"id"`
	Name           string `json:"name"`
	Bio            string `json:"bio,omitempty"`
	ImageURL       string `json:"image_url,omitempty"`
	Verified       bool   `json:"verified"`
	FollowersCount int    `json:"followers_count"`
}

func ToResponse(a Artist) ArtistResponse {
	return ArtistResponse{
		ID:             a.ID,
		Name:           a.Name,
		Bio:            a.Bio,
		ImageURL:       a.ImageURL,
		Verified:       a.Verified,
		FollowersCount: a.FollowersCount,
	}
}
