package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/song"
)

func SongRoutes(r chi.Router, h *song.Handler) {
	r.Route("/songs", func(r chi.Router) {
		r.Post("/", h.Create)
		r.Get("/", h.List)
		r.Get("/mine", h.ListMine)
		r.Get("/{id}", h.Get)
		r.Delete("/{id}", h.Delete)
	})
}
