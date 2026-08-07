package playlist

import (
	"encoding/json"
	"net/http"
	"strconv"

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

func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromCtx(r)
	if !ok {
		response.Error(w, http.StatusUnauthorized, "UNAUTHORIZED", "not authenticated")
		return
	}
	var req CreatePlaylistRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	res, err := h.service.Create(r.Context(), userID, req)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "CREATE_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusCreated, res)
}

func (h *Handler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromCtx(r)
	if !ok {
		response.Error(w, http.StatusUnauthorized, "UNAUTHORIZED", "not authenticated")
		return
	}
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))

	res, err := h.service.ListByUser(r.Context(), userID, limit, offset)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "LIST_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}

func (h *Handler) Get(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	res, err := h.service.Get(r.Context(), id)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", "playlist not found")
		return
	}
	response.JSON(w, http.StatusOK, res)
}

func (h *Handler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.service.Delete(r.Context(), id); err != nil {
		response.Error(w, http.StatusInternalServerError, "DELETE_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, map[string]string{"message": "deleted"})
}

func (h *Handler) AddSong(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var req AddSongRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	if err := h.service.AddSong(r.Context(), id, req); err != nil {
		response.Error(w, http.StatusBadRequest, "ADD_SONG_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, map[string]string{"message": "song added"})
}

func (h *Handler) RemoveSong(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	songID := chi.URLParam(r, "songId")
	if err := h.service.RemoveSong(r.Context(), id, songID); err != nil {
		response.Error(w, http.StatusInternalServerError, "REMOVE_SONG_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, map[string]string{"message": "song removed"})
}
