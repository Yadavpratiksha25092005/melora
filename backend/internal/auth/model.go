package auth

import "time"

type User struct {
	ID          string     `json:"id"`
	Name        string     `json:"name,omitempty"`
	PhoneNumber string     `json:"phone_number"`
	IsAdmin     bool       `json:"is_admin"`
	OTPCode     string     `json:"-"`
	OTPExpires  *time.Time `json:"-"`
	CreatedAt   time.Time  `json:"created_at"`
}
