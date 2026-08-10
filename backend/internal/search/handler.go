package search

import (
	"net/http"

	"spotify-clone-backend/pkg/response"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) Search(w http.ResponseWriter, r *http.Request) {
	query := r.URL.Query().Get("q")

	res, err := h.service.Search(r.Context(), query)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "SEARCH_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}
