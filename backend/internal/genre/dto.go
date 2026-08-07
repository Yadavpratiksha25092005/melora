package genre

type CreateGenreRequest struct {
	Name string `json:"name"`
}

type GenreResponse struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

func ToResponse(g Genre) GenreResponse {
	return GenreResponse{ID: g.ID, Name: g.Name}
}
