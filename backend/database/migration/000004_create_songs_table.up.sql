CREATE EXTENSION IF NOT EXISTS "pg_trgm";

CREATE TABLE songs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    album_id UUID REFERENCES albums(id) ON DELETE SET NULL,
    artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    duration_ms INTEGER NOT NULL DEFAULT 0,
    file_url TEXT NOT NULL,
    cover_url TEXT,
    genre VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_songs_artist_id ON songs(artist_id);
CREATE INDEX idx_songs_album_id ON songs(album_id);
CREATE INDEX idx_songs_title_trgm ON songs USING gin (title gin_trgm_ops);
