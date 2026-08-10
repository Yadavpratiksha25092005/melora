package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	Port        string
	DatabaseURL string
	JWTSecret   string
	S3Bucket    string
	S3Endpoint  string
	S3Region    string
	S3AccessKey string
	S3SecretKey string
	Env         string
}

func Load() *Config {
	if err := godotenv.Load(); err != nil {
		log.Println("no .env file found, using system environment variables")
	}

	return &Config{
		Port:        getEnv("PORT", "8080"),
		DatabaseURL: getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/spotify_clone?sslmode=disable"),
		JWTSecret:   getEnv("JWT_SECRET", "change_me_in_production"),
		S3Bucket:    getEnv("S3_BUCKET", ""),
		S3Endpoint:  getEnv("S3_ENDPOINT", "localhost:9000"),
		S3Region:    getEnv("S3_REGION", ""),
		S3AccessKey: getEnv("S3_ACCESS_KEY", ""),
		S3SecretKey: getEnv("S3_SECRET_KEY", ""),
		Env:         getEnv("ENV", "development"),
	}
}

func getEnv(key, fallback string) string {
	if val, ok := os.LookupEnv(key); ok {
		return val
	}
	return fallback
}
