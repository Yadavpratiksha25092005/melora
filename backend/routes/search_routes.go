package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/search"
)

func SearchRoutes(r chi.Router, h *search.Handler) {
	r.Get("/search", h.Search)
}
