ALTER TABLE artists ADD COLUMN owner_user_id UUID REFERENCES users(id) ON DELETE SET NULL;
CREATE INDEX idx_artists_owner_user_id ON artists(owner_user_id);