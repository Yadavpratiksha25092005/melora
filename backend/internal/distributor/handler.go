package distributor

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/pkg/response"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{service: service}
}

// POST /artist/upload-song
func (h *Handler) UploadSong(w http.ResponseWriter, r *http.Request) {
	var req UploadSongRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	res, err := h.service.UploadSong(r.Context(), req)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "UPLOAD_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusCreated, res)
}

// GET /distributor/pending
func (h *Handler) ListPending(w http.ResponseWriter, r *http.Request) {
	res, err := h.service.ListPending(r.Context())
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "LIST_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}

// POST /distributor/approve/{id}
func (h *Handler) Approve(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.service.Approve(r.Context(), id); err != nil {
		response.Error(w, http.StatusInternalServerError, "APPROVE_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, map[string]string{"message": "song published"})
}

// POST /distributor/reject/{id}
func (h *Handler) Reject(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.service.Reject(r.Context(), id); err != nil {
		response.Error(w, http.StatusInternalServerError, "REJECT_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, map[string]string{"message": "song rejected"})
}
