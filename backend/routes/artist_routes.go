package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/artist"
	"spotify-clone-backend/middleware"
)

func ArtistRoutes(r chi.Router, h *artist.Handler, jwtSecret string) {
	r.Route("/artists", func(r chi.Router) {
		r.Get("/", h.List)
		r.Get("/{id}", h.Get)

		r.Group(func(r chi.Router) {
			r.Use(middleware.Auth(jwtSecret))
			r.Post("/", h.Create)
			r.Get("/me", h.GetMine)
			r.Put("/{id}", h.Update)
			r.Delete("/{id}", h.Delete)
		})
	})
}
