package auth

import "time"

type User struct {
	ID           string     `json:"id"`
	Name         string     `json:"name,omitempty"`
	Email        string     `json:"email"`
	PasswordHash string     `json:"-"`
	PhoneNumber  string     `json:"phone_number,omitempty"`
	IsAdmin      bool       `json:"is_admin"`
	OTPCode      string     `json:"-"`
	OTPExpires   *time.Time `json:"-"`
	CreatedAt    time.Time  `json:"created_at"`
}
