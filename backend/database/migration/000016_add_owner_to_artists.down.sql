DROP INDEX IF EXISTS idx_artists_owner_user_id;
ALTER TABLE artists DROP COLUMN IF EXISTS owner_user_id;