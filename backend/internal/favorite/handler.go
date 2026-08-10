package favorite

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/middleware"
	"spotify-clone-backend/pkg/response"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{service: service}
}

func userIDFromCtx(r *http.Request) (string, bool) {
	id, ok := r.Context().Value(middleware.UserIDKey).(string)
	return id, ok && id != ""
}

func (h *Handler) Add(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromCtx(r)
	if !ok {
		response.Error(w, http.StatusUnauthorized, "UNAUTHORIZED", "not authenticated")
		return
	}
	var req AddFavoriteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	if err := h.service.Add(r.Context(), userID, req); err != nil {
		response.Error(w, http.StatusBadRequest, "ADD_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, map[string]string{"message": "added to favorites"})
}

func (h *Handler) Remove(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromCtx(r)
	if !ok {
		response.Error(w, http.StatusUnauthorized, "UNAUTHORIZED", "not authenticated")
		return
	}
	songID := chi.URLParam(r, "songId")
	if err := h.service.Remove(r.Context(), userID, songID); err != nil {
		response.Error(w, http.StatusInternalServerError, "REMOVE_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, map[string]string{"message": "removed from favorites"})
}

func (h *Handler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromCtx(r)
	if !ok {
		response.Error(w, http.StatusUnauthorized, "UNAUTHORIZED", "not authenticated")
		return
	}
	songs, err := h.service.ListByUser(r.Context(), userID)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "LIST_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, songs)
}
