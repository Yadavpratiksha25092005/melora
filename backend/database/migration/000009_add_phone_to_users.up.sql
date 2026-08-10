ALTER TABLE users ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE users ALTER COLUMN email DROP NOT NULL;
ALTER TABLE users ADD CONSTRAINT users_phone_number_unique UNIQUE (phone_number);