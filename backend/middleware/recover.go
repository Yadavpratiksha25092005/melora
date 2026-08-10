package middleware

import (
	"log"
	"net/http"

	"spotify-clone-backend/pkg/response"
)

func Recover(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				log.Printf("panic recovered: %v", err)
				response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", "something went wrong")
			}
		}()
		next.ServeHTTP(w, r)
	})
}
