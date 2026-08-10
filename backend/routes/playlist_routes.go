package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/playlist"
	"spotify-clone-backend/middleware"
)

func PlaylistRoutes(r chi.Router, h *playlist.Handler, jwtSecret string) {
	r.Route("/playlists", func(r chi.Router) {
		r.Use(middleware.Auth(jwtSecret))

		r.Post("/", h.Create)
		r.Get("/", h.List)
		r.Get("/{id}", h.Get)
		r.Delete("/{id}", h.Delete)
		r.Post("/{id}/songs", h.AddSong)
		r.Delete("/{id}/songs/{songId}", h.RemoveSong)
	})
}
