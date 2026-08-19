package auth

type SignupRequest struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type ForgotPasswordRequest struct {
	Email       string `json:"email"`
	NewPassword string `json:"new_password"`
}

type UpdateNameRequest struct {
	Name string `json:"name"`
}

type UserResponse struct {
	ID          string `json:"id"`
	Name        string `json:"name,omitempty"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number,omitempty"`
	IsAdmin     bool   `json:"is_admin"`
}

type AuthResponse struct {
	Token string       `json:"token"`
	User  UserResponse `json:"user"`
}

func ToUserResponse(u User) UserResponse {
	return UserResponse{ID: u.ID, Name: u.Name, Email: u.Email, PhoneNumber: u.PhoneNumber, IsAdmin: u.IsAdmin}
}
