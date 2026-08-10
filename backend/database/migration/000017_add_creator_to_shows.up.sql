ALTER TABLE shows ADD COLUMN creator_user_id UUID REFERENCES users(id) ON DELETE SET NULL;
CREATE INDEX idx_shows_creator_user_id ON shows(creator_user_id);