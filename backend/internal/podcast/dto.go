package podcast

type CreateShowRequest struct {
	Title       string `json:"title"`
	HostName    string `json:"host_name"`
	Description string `json:"description"`
	CoverURL    string `json:"cover_url"`
}

type CreateEpisodeRequest struct {
	ShowID        string `json:"show_id"`
	Title         string `json:"title"`
	Description   string `json:"description"`
	AudioURL      string `json:"audio_url"`
	VideoURL      string `json:"video_url"`
	CoverURL      string `json:"cover_url"`
	DurationMs    int    `json:"duration_ms"`
	EpisodeNumber int    `json:"episode_number"`
}

type ShowResponse struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	HostName    string `json:"host_name,omitempty"`
	Description string `json:"description,omitempty"`
	CoverURL    string `json:"cover_url,omitempty"`
}

type EpisodeResponse struct {
	ID            string `json:"id"`
	ShowID        string `json:"show_id"`
	Title         string `json:"title"`
	Description   string `json:"description,omitempty"`
	AudioURL      string `json:"audio_url,omitempty"`
	VideoURL      string `json:"video_url,omitempty"`
	CoverURL      string `json:"cover_url,omitempty"`
	DurationMs    int    `json:"duration_ms,omitempty"`
	EpisodeNumber int    `json:"episode_number,omitempty"`
	HasVideo      bool   `json:"has_video"`
}

func ToShowResponse(s Show) ShowResponse {
	return ShowResponse{
		ID: s.ID, Title: s.Title, HostName: s.HostName,
		Description: s.Description, CoverURL: s.CoverURL,
	}
}

func ToEpisodeResponse(e Episode) EpisodeResponse {
	return EpisodeResponse{
		ID: e.ID, ShowID: e.ShowID, Title: e.Title, Description: e.Description,
		AudioURL: e.AudioURL, VideoURL: e.VideoURL, CoverURL: e.CoverURL,
		DurationMs: e.DurationMs, EpisodeNumber: e.EpisodeNumber,
		HasVideo: e.VideoURL != "",
	}
}
