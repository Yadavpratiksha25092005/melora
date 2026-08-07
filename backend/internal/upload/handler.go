package upload

import (
	"fmt"
	"net/http"

	"github.com/google/uuid"

	"spotify-clone-backend/pkg/response"
	"spotify-clone-backend/pkg/s3"
)

type Handler struct {
	s3Client *s3.Client
}

func NewHandler(s3Client *s3.Client) *Handler {
	return &Handler{s3Client: s3Client}
}

const maxUploadSize = 50 << 20 // 50MB

// POST /upload/song  (multipart form field name: "audio")
func (h *Handler) UploadSong(w http.ResponseWriter, r *http.Request) {
	h.uploadFile(w, r, "audio", "songs")
}

// POST /upload/image (multipart form field name: "image")
func (h *Handler) UploadImage(w http.ResponseWriter, r *http.Request) {
	h.uploadFile(w, r, "image", "images")
}

func (h *Handler) uploadFile(w http.ResponseWriter, r *http.Request, fieldName, folder string) {
	r.Body = http.MaxBytesReader(w, r.Body, maxUploadSize)
	if err := r.ParseMultipartForm(maxUploadSize); err != nil {
		response.Error(w, http.StatusBadRequest, "FILE_TOO_LARGE", "file exceeds 50MB limit")
		return
	}

	file, header, err := r.FormFile(fieldName)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "MISSING_FILE", fmt.Sprintf("form field %q is required", fieldName))
		return
	}
	defer file.Close()

	key := fmt.Sprintf("%s/%s-%s", folder, uuid.NewString(), header.Filename)
	url, err := h.s3Client.Upload(r.Context(), key, file, header.Size, header.Header.Get("Content-Type"))
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "UPLOAD_FAILED", err.Error())
		return
	}

	response.JSON(w, http.StatusOK, map[string]string{"url": url})
}
