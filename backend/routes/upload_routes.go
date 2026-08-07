package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/upload"
	"spotify-clone-backend/middleware"
)

func UploadRoutes(r chi.Router, h *upload.Handler, jwtSecret string) {
	r.Route("/upload", func(r chi.Router) {
		r.Use(middleware.Auth(jwtSecret)) // only logged-in (admin) users can upload

		r.Post("/song", h.UploadSong)
		r.Post("/image", h.UploadImage)
	})
}
