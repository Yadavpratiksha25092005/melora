package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/history"
	"spotify-clone-backend/middleware"
)

func HistoryRoutes(r chi.Router, h *history.Handler, jwtSecret string) {
	r.Route("/history", func(r chi.Router) {
		r.Use(middleware.Auth(jwtSecret))

		r.Post("/", h.Add)
		r.Get("/", h.List)
	})
}
