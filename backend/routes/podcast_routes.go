package routes

import (
	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/internal/podcast"
	"spotify-clone-backend/middleware"
)

func PodcastRoutes(r chi.Router, h *podcast.Handler, jwtSecret string) {
	r.Route("/shows", func(r chi.Router) {
		r.Get("/", h.ListShows)
		r.Get("/{id}", h.GetShow)
		r.Get("/{id}/episodes", h.ListEpisodesByShow)

		r.Group(func(r chi.Router) {
			r.Use(middleware.Auth(jwtSecret))
			r.Post("/", h.CreateShow)
			r.Get("/mine", h.ListMyShows)
		})
	})

	r.Route("/episodes", func(r chi.Router) {
		r.Post("/", h.CreateEpisode)
		r.Get("/{id}", h.GetEpisode)
	})
}
