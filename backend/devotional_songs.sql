INSERT INTO songs (artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ((SELECT id FROM artists WHERE name = 'Anuradha Paudwal' ORDER BY created_at DESC LIMIT 1), 'Gayatri Mantra', 300000, '', '', 'Devotional', 'Sanskrit', '', 'PUBLISHED', 0);

INSERT INTO songs (artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ((SELECT id FROM artists WHERE name = 'Shankar Sahney' ORDER BY created_at DESC LIMIT 1), 'Mahamrityunjaya Mantra', 300000, '', '', 'Devotional', 'Sanskrit', '', 'PUBLISHED', 0);

INSERT INTO songs (artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ((SELECT id FROM artists WHERE name = 'Suresh Wadkar' ORDER BY created_at DESC LIMIT 1), 'Om Namah Shivaya', 300000, '', '', 'Devotional', 'Sanskrit', '', 'PUBLISHED', 0);

INSERT INTO songs (artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ((SELECT id FROM artists WHERE name = 'Anuradha Paudwal' ORDER BY created_at DESC LIMIT 1), 'Om Gan Ganpataye Namo Namah', 300000, '', '', 'Devotional', 'Sanskrit', '', 'PUBLISHED', 0);

INSERT INTO songs (artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ((SELECT id FROM artists WHERE name = 'Suresh Wadkar' ORDER BY created_at DESC LIMIT 1), 'Hanuman Mantra', 300000, '', '', 'Devotional', 'Sanskrit', '', 'PUBLISHED', 0);

INSERT INTO songs (artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ((SELECT id FROM artists WHERE name = 'Ashit Desai' ORDER BY created_at DESC LIMIT 1), 'Shri Krishna Dwadashnaam', 300000, '', '', 'Devotional', 'Sanskrit', '', 'PUBLISHED', 0);

INSERT INTO songs (artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ((SELECT id FROM artists WHERE name = 'Vijay Prakash' ORDER BY created_at DESC LIMIT 1), 'Shri Lakshmi Mahamantra', 300000, '', '', 'Devotional', 'Sanskrit', '', 'PUBLISHED', 0);

INSERT INTO songs (artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ((SELECT id FROM artists WHERE name = 'Vijay Prakash' ORDER BY created_at DESC LIMIT 1), 'Ganesh Atharvashirsha', 300000, '', '', 'Devotional', 'Sanskrit', '', 'PUBLISHED', 0);

INSERT INTO songs (artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ((SELECT id FROM artists WHERE name = 'Suresh Wadkar' ORDER BY created_at DESC LIMIT 1), 'Hanuman Dhun', 300000, '', '', 'Devotional', 'Sanskrit', '', 'PUBLISHED', 0);

INSERT INTO songs (artist_id, title, duration_ms, file_url, cover_url, genre, language, lyrics, status, play_count)
VALUES ((SELECT id FROM artists WHERE name = 'Anuradha Paudwal' ORDER BY created_at DESC LIMIT 1), 'Durga Mantra', 300000, '', '', 'Devotional', 'Sanskrit', '', 'PUBLISHED', 0);
