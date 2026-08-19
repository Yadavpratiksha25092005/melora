package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/auth"
	"spotify-clone-backend/middleware"
)

func AuthRoutes(r chi.Router, h *auth.Handler, jwtSecret string) {
	r.Route("/auth", func(r chi.Router) {
		r.Post("/signup", h.Signup)
		r.Post("/login", h.Login)
		r.Post("/forgot-password", h.ForgotPassword)

		r.Group(func(r chi.Router) {
			r.Use(middleware.Auth(jwtSecret))
			r.Get("/profile", h.Profile)
			r.Put("/profile/name", h.UpdateName)
		})
	})
}
