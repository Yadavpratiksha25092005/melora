DROP INDEX IF EXISTS idx_shows_creator_user_id;
ALTER TABLE shows DROP COLUMN IF EXISTS creator_user_id;