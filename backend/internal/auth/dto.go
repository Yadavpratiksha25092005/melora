package auth

type SendOTPRequest struct {
	Phone string `json:"phone"`
}

type VerifyOTPRequest struct {
	Phone string `json:"phone"`
	OTP   string `json:"otp"`
}

type UserResponse struct {
	ID          string `json:"id"`
	Name        string `json:"name,omitempty"`
	PhoneNumber string `json:"phone_number"`
	IsAdmin     bool   `json:"is_admin"`
}

type VerifyOTPResponse struct {
	Token string       `json:"token"`
	User  UserResponse `json:"user"`
}

func ToUserResponse(u User) UserResponse {
	return UserResponse{ID: u.ID, Name: u.Name, PhoneNumber: u.PhoneNumber, IsAdmin: u.IsAdmin}
}
