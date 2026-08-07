package main

import (
	"log"
	"net/http"

	"spotify-clone-backend/config"
	"spotify-clone-backend/database"
	"spotify-clone-backend/pkg/s3"
	"spotify-clone-backend/routes"
)

func main() {
	cfg := config.Load()

	db := database.Connect(cfg.DatabaseURL)
	defer db.Close()

	s3Client, err := s3.NewClient(cfg.S3Endpoint, cfg.S3AccessKey, cfg.S3SecretKey, cfg.S3Bucket, false)
	if err != nil {
		log.Fatalf("unable to connect to MinIO: %v", err)
	}

	router := routes.Setup(db, cfg.JWTSecret, s3Client)

	log.Printf("server running on :%s (env=%s)", cfg.Port, cfg.Env)
	if err := http.ListenAndServe(":"+cfg.Port, router); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}
