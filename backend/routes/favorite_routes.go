package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/favorite"
	"spotify-clone-backend/middleware"
)

func FavoriteRoutes(r chi.Router, h *favorite.Handler, jwtSecret string) {
	r.Route("/favorites", func(r chi.Router) {
		r.Use(middleware.Auth(jwtSecret))

		r.Post("/", h.Add)
		r.Get("/", h.List)
		r.Delete("/{songId}", h.Remove)
	})
}
