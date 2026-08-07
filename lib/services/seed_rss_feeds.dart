// These are well-known, long-running shows hosted on their platform's
// own stable CDN (NPR, BBC) — good starting points. VERIFY each by
// pasting it into a browser first (should show raw XML starting with
// <?xml version="1.0"?>) before shipping, since I can't fetch/confirm
// URLs live from here — RSS feed addresses do occasionally change when
// a show switches hosting providers.
//
// You can swap in ANY podcast's feed — every podcast has one; see
// "How to find any show's RSS feed" note below.

const List<String> seedRssFeeds = [
  'https://feeds.npr.org/510298/podcast.xml',              // NPR: TED Radio Hour
  'https://podcasts.files.bbci.co.uk/p02nq0gn.rss',        // BBC: Global News Podcast
  'https://feeds.megaphone.fm/stuffyoushouldknow',         // Stuff You Should Know
];

// -----------------------------------------------------------------
// How to find any show's RSS feed (for adding more):
// 1. Go to https://rss.com/tools/find-my-feed/  (or podcastindex.org
//    website search — same catalog, but this needs no signup)
// 2. Search the show's name, or paste its Apple Podcasts link.
// 3. Copy the "RSS Feed" URL it gives you.
// 4. Add it to the seedRssFeeds list above.
// -----------------------------------------------------------------