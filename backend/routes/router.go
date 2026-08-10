package routes

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	"github.com/jackc/pgx/v5/pgxpool"

	"spotify-clone-backend/internal/admin"
	"spotify-clone-backend/internal/album"
	"spotify-clone-backend/internal/artist"
	"spotify-clone-backend/internal/auth"
	"spotify-clone-backend/internal/distributor"
	"spotify-clone-backend/internal/favorite"
	"spotify-clone-backend/internal/genre"
	"spotify-clone-backend/internal/history"
	"spotify-clone-backend/internal/playlist"
	"spotify-clone-backend/internal/podcast"
	"spotify-clone-backend/internal/search"
	"spotify-clone-backend/internal/song"
	"spotify-clone-backend/internal/upload"
	"spotify-clone-backend/internal/user"
	"spotify-clone-backend/middleware"
	"spotify-clone-backend/pkg/s3"
)

func Setup(db *pgxpool.Pool, jwtSecret string, s3Client *s3.Client) http.Handler {
	r := chi.NewRouter()

	r.Use(chimiddleware.RequestID)
	r.Use(middleware.Recover)
	r.Use(middleware.Logger)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: true,
	}))

	r.Get("/health", func(w http.ResponseWriter, req *http.Request) {
		w.Write([]byte("ok"))
	})

	// wire up modules
	authRepo := auth.NewRepository(db)
	authService := auth.NewService(authRepo, jwtSecret, true)
	authHandler := auth.NewHandler(authService)
	songRepo := song.NewRepository(db)
	songService := song.NewService(songRepo)
	songHandler := song.NewHandler(songService)

	artistRepo := artist.NewRepository(db)
	artistService := artist.NewService(artistRepo)
	artistHandler := artist.NewHandler(artistService)

	albumRepo := album.NewRepository(db)
	albumService := album.NewService(albumRepo)
	albumHandler := album.NewHandler(albumService)

	playlistRepo := playlist.NewRepository(db)
	playlistService := playlist.NewService(playlistRepo)
	playlistHandler := playlist.NewHandler(playlistService)

	favoriteRepo := favorite.NewRepository(db)
	favoriteService := favorite.NewService(favoriteRepo)
	favoriteHandler := favorite.NewHandler(favoriteService)

	historyRepo := history.NewRepository(db)
	historyService := history.NewService(historyRepo)
	historyHandler := history.NewHandler(historyService)

	searchRepo := search.NewRepository(db)
	searchService := search.NewService(searchRepo)
	searchHandler := search.NewHandler(searchService)
	uploadHandler := upload.NewHandler(s3Client)

	genreRepo := genre.NewRepository(db)
	genreService := genre.NewService(genreRepo)
	genreHandler := genre.NewHandler(genreService)

	userRepo := user.NewRepository(db)
	userService := user.NewService(userRepo)
	userHandler := user.NewHandler(userService)

	distributorRepo := distributor.NewRepository(db)
	distributorService := distributor.NewService(distributorRepo)
	distributorHandler := distributor.NewHandler(distributorService)

	podcastRepo := podcast.NewRepository(db)
	podcastService := podcast.NewService(podcastRepo)
	podcastHandler := podcast.NewHandler(podcastService)

	adminRepo := admin.NewRepository(db)
	adminService := admin.NewService(adminRepo)
	adminHandler := admin.NewHandler(adminService)

	r.Route("/api/v1", func(r chi.Router) {
		AuthRoutes(r, authHandler, jwtSecret)
		SongRoutes(r, songHandler)
		ArtistRoutes(r, artistHandler, jwtSecret)
		AlbumRoutes(r, albumHandler)
		PlaylistRoutes(r, playlistHandler, jwtSecret)
		FavoriteRoutes(r, favoriteHandler, jwtSecret)
		HistoryRoutes(r, historyHandler, jwtSecret)
		SearchRoutes(r, searchHandler)
		UploadRoutes(r, uploadHandler, jwtSecret)
		GenreRoutes(r, genreHandler)
		UserRoutes(r, userHandler, jwtSecret)
		DistributorRoutes(r, distributorHandler, jwtSecret)
		PodcastRoutes(r, podcastHandler, jwtSecret)
		AdminRoutes(r, adminHandler, jwtSecret)
		// TODO: UserRoutes, ArtistRoutes, AlbumRoutes, GenreRoutes,
		// PlaylistRoutes, SearchRoutes, FavoriteRoutes, HistoryRoutes,
		// StreamingRoutes, UploadRoutes, AdminRoutes — follow the same
		// pattern as auth/song: repository -> service -> handler -> routes
	})

	return r
}
