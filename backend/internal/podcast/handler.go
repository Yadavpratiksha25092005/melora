package podcast

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

func (h *Handler) CreateShow(w http.ResponseWriter, r *http.Request) {
	var req CreateShowRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	var creatorUserID *string
	if uid, ok := r.Context().Value(middleware.UserIDKey).(string); ok && uid != "" {
		creatorUserID = &uid
	}
	res, err := h.service.CreateShow(r.Context(), req, creatorUserID)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "CREATE_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusCreated, res)
}

func (h *Handler) ListMyShows(w http.ResponseWriter, r *http.Request) {
	uid, ok := r.Context().Value(middleware.UserIDKey).(string)
	if !ok || uid == "" {
		response.Error(w, http.StatusUnauthorized, "UNAUTHORIZED", "not authenticated")
		return
	}
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))
	res, err := h.service.ListMyShows(r.Context(), uid, limit, offset)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "LIST_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}

func (h *Handler) ListShows(w http.ResponseWriter, r *http.Request) {
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))
	res, err := h.service.ListShows(r.Context(), limit, offset)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "LIST_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}

func (h *Handler) GetShow(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	res, err := h.service.GetShow(r.Context(), id)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", "show not found")
		return
	}
	response.JSON(w, http.StatusOK, res)
}

func (h *Handler) CreateEpisode(w http.ResponseWriter, r *http.Request) {
	var req CreateEpisodeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	res, err := h.service.CreateEpisode(r.Context(), req)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "CREATE_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusCreated, res)
}

func (h *Handler) ListEpisodesByShow(w http.ResponseWriter, r *http.Request) {
	showID := chi.URLParam(r, "id")
	res, err := h.service.ListEpisodesByShow(r.Context(), showID)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "LIST_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}

func (h *Handler) GetEpisode(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	res, err := h.service.GetEpisode(r.Context(), id)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", "episode not found")
		return
	}
	response.JSON(w, http.StatusOK, res)
}
