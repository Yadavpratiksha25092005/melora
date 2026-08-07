package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/user"
	"spotify-clone-backend/middleware"
)

func UserRoutes(r chi.Router, h *user.Handler, jwtSecret string) {
	r.Route("/users", func(r chi.Router) {
		r.Use(middleware.Auth(jwtSecret))
		r.Put("/profile", h.UpdateProfile)
	})
}
