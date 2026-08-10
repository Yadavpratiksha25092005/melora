package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/album"
)

func AlbumRoutes(r chi.Router, h *album.Handler) {
	r.Route("/albums", func(r chi.Router) {
		r.Post("/", h.Create)
		r.Get("/", h.List)
		r.Get("/{id}", h.Get)
		r.Put("/{id}", h.Update)
		r.Delete("/{id}", h.Delete)
	})
}
