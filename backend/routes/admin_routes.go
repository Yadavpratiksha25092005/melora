package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/admin"
	"spotify-clone-backend/middleware"
)

func AdminRoutes(r chi.Router, h *admin.Handler, jwtSecret string) {
	r.Route("/admin", func(r chi.Router) {
		r.Use(middleware.Auth(jwtSecret))

		r.Get("/dashboard", h.Dashboard)
		r.Get("/users", h.ListUsers)
		r.Delete("/users/{id}", h.DeleteUser)
	})
}
