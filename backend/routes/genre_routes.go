package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/genre"
)

func GenreRoutes(r chi.Router, h *genre.Handler) {
	r.Route("/genres", func(r chi.Router) {
		r.Post("/", h.Create)
		r.Get("/", h.List)
		r.Delete("/{id}", h.Delete)
	})
}
