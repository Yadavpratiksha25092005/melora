package user

type UpdateProfileRequest struct {
	Name      string `json:"name"`
	AvatarURL string `json:"avatar_url"`
}

type UserResponse struct {
	ID          string `json:"id"`
	Name        string `json:"name,omitempty"`
	PhoneNumber string `json:"phone_number"`
	AvatarURL   string `json:"avatar_url,omitempty"`
}
