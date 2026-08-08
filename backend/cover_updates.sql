-- Sets cover_url to a bundled local asset path (not an http URL) for
-- songs whose titles match images already in assets/images/songs/ or
-- assets/images/. The app's hasLocalCover() check treats any non-http
-- cover_url as a local asset and renders it via Image.asset() directly.

UPDATE songs SET cover_url = 'assets/images/songs/kal_ho_na_ho.jpg' WHERE title = 'Kal Ho Naa Ho';
UPDATE songs SET cover_url = 'assets/images/tum_hi_ho.jpg' WHERE title = 'Tum Hi Ho';
UPDATE songs SET cover_url = 'assets/images/songs/butta_bomma.jpg' WHERE title = 'Butta Bomma';
UPDATE songs SET cover_url = 'assets/images/songs/tera_ban_jaunga.jpg' WHERE title = 'Tera Ban Jaunga';
UPDATE songs SET cover_url = 'assets/images/songs/kar_gayi_chull.jpg' WHERE title = 'Kar Gayi Chull';
UPDATE songs SET cover_url = 'assets/images/songs/sun_raha_hai_na_tu.png' WHERE title = 'Sun Raha Hai Na Tu';
UPDATE songs SET cover_url = 'assets/images/songs/Ye_re_ye_re_paisa_jpg.jpg' WHERE title = 'Ye Re Ye Re Paisa';
UPDATE songs SET cover_url = 'assets/images/songs/ilahi.jpg' WHERE title = 'Ilahi';
UPDATE songs SET cover_url = 'assets/images/songs/tujhe_kitna_chahne_lage.jpg' WHERE title = 'Tujhe Kitna Chahne Lage';
UPDATE songs SET cover_url = 'assets/images/songs/abhi_toh_party_shuru_hui_hai.jpg' WHERE title = 'Abhi Toh Party Shuru Hui Hai';
UPDATE songs SET cover_url = 'assets/images/songs/ziddi_dil.jpg' WHERE title = 'Ziddi Dil';
UPDATE songs SET cover_url = 'assets/images/songs/dj_waley_babu.jpg' WHERE title = 'DJ Waley Babu';
UPDATE songs SET cover_url = 'assets/images/songs/pal_pal_dil_ke_pass.jpg' WHERE title = 'Pal Pal Dil Ke Paas';
UPDATE songs SET cover_url = 'assets/images/songs/butta_bomma.jpg' WHERE title = 'Buttabomma';
UPDATE songs SET cover_url = 'assets/images/songs/vajle_ki_bara.jpg' WHERE title = 'Vaajle Ki Baara';
UPDATE songs SET cover_url = 'assets/images/songs/kombdi_palali.jpg' WHERE title = 'Kombdi Palali';