package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/distributor"
	"spotify-clone-backend/middleware"
)

func DistributorRoutes(r chi.Router, h *distributor.Handler, jwtSecret string) {
	// artist-facing upload endpoint
	r.Route("/artist", func(r chi.Router) {
		r.Use(middleware.Auth(jwtSecret))
		r.Post("/upload-song", h.UploadSong)
	})

	// admin-facing review endpoints
	r.Route("/distributor", func(r chi.Router) {
		r.Use(middleware.Auth(jwtSecret)) // TODO: add an admin-only check here once roles are enforced
		r.Get("/pending", h.ListPending)
		r.Post("/approve/{id}", h.Approve)
		r.Post("/reject/{id}", h.Reject)
	})
}
