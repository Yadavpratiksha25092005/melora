package auth

import (
	"encoding/json"
	"net/http"

	"spotify-clone-backend/middleware"
	"spotify-clone-backend/pkg/response"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{service: service}
}

// POST /auth/signup
func (h *Handler) Signup(w http.ResponseWriter, r *http.Request) {
	var req SignupRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	res, err := h.service.Signup(r.Context(), req)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "SIGNUP_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}

// POST /auth/login
func (h *Handler) Login(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	res, err := h.service.Login(r.Context(), req)
	if err != nil {
		response.Error(w, http.StatusUnauthorized, "LOGIN_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}

// POST /auth/forgot-password
func (h *Handler) ForgotPassword(w http.ResponseWriter, r *http.Request) {
	var req ForgotPasswordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	if err := h.service.ForgotPassword(r.Context(), req); err != nil {
		response.Error(w, http.StatusBadRequest, "RESET_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, map[string]string{"message": "Password updated"})
}

// GET /auth/profile (protected)
func (h *Handler) Profile(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.UserIDKey).(string)
	if !ok || userID == "" {
		response.Error(w, http.StatusUnauthorized, "UNAUTHORIZED", "not authenticated")
		return
	}
	res, err := h.service.Profile(r.Context(), userID)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", "user not found")
		return
	}
	response.JSON(w, http.StatusOK, res)
}

// PUT /auth/profile/name (protected)
func (h *Handler) UpdateName(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(middleware.UserIDKey).(string)
	if !ok || userID == "" {
		response.Error(w, http.StatusUnauthorized, "UNAUTHORIZED", "not authenticated")
		return
	}
	var req UpdateNameRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	res, err := h.service.UpdateName(r.Context(), userID, req.Name)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "UPDATE_NAME_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
}
