package artist

import "time"

type Artist struct {
	ID             string    `json:"id"`
	Name           string    `json:"name"`
	Bio            string    `json:"bio,omitempty"`
	ImageURL       string    `json:"image_url,omitempty"`
	Verified       bool      `json:"verified"`
	FollowersCount int       `json:"followers_count"`
	OwnerUserID    *string   `json:"owner_user_id,omitempty"`
	CreatedAt      time.Time `json:"created_at"`
}
