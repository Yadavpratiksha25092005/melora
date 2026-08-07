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

// POST /auth/otp/send
func (h *Handler) SendOTP(w http.ResponseWriter, r *http.Request) {
	var req SendOTPRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	if err := h.service.SendOTP(r.Context(), req); err != nil {
		response.Error(w, http.StatusBadRequest, "SEND_OTP_FAILED", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, map[string]string{"message": "OTP sent"})
}

// POST /auth/otp/verify
func (h *Handler) VerifyOTP(w http.ResponseWriter, r *http.Request) {
	var req VerifyOTPRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_BODY", "could not parse request body")
		return
	}
	res, err := h.service.VerifyOTP(r.Context(), req)
	if err != nil {
		response.Error(w, http.StatusUnauthorized, "INVALID_OTP", err.Error())
		return
	}
	response.JSON(w, http.StatusOK, res)
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
