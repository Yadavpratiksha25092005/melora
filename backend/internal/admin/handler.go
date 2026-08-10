package admin

import (
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	"spotify-clone-backend/pkg/response"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) Dashboard(w http.ResponseWriter, r *http.Request) {
	res, err := h.service.Dashboard(r.Context())
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "DASHBOARD_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}

func (h *Handler) ListUsers(w http.ResponseWriter, r *http.Request) {
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))

	res, err := h.service.ListUsers(r.Context(), limit, offset)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "LIST_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}

func (h *Handler) DeleteUser(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.service.DeleteUser(r.Context(), id); err != nil {
		response.Error(w, http.StatusInternalServerError, "DELETE_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, map[string]string{"message": "user deleted"})
}
