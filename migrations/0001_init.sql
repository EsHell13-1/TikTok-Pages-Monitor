PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS channels (
 id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, profile_url TEXT NOT NULL,
 display_name TEXT, follower_count INTEGER, following_count INTEGER, total_likes INTEGER, video_count INTEGER,
 enabled INTEGER NOT NULL DEFAULT 1, last_checked_at TEXT, last_error TEXT,
 created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE TABLE IF NOT EXISTS videos (
 id TEXT PRIMARY KEY, channel_id INTEGER NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
 url TEXT NOT NULL, description TEXT, created_at_tiktok TEXT, duration_seconds INTEGER,
 views INTEGER, likes INTEGER, comments INTEGER, shares INTEGER, favorites INTEGER,
 first_seen_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 last_seen_at TEXT, last_error TEXT
);
CREATE INDEX IF NOT EXISTS idx_videos_channel ON videos(channel_id);
CREATE TABLE IF NOT EXISTS snapshots (
 id INTEGER PRIMARY KEY AUTOINCREMENT, video_id TEXT NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
 captured_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 views INTEGER, likes INTEGER, comments INTEGER, shares INTEGER, favorites INTEGER
);
CREATE INDEX IF NOT EXISTS idx_snapshots_video_time ON snapshots(video_id,captured_at);
CREATE INDEX IF NOT EXISTS idx_snapshots_time ON snapshots(captured_at);
CREATE TABLE IF NOT EXISTS channel_snapshots (
 id INTEGER PRIMARY KEY AUTOINCREMENT, channel_id INTEGER NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
 captured_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 follower_count INTEGER, following_count INTEGER, total_likes INTEGER, video_count INTEGER
);
CREATE INDEX IF NOT EXISTS idx_channel_snapshots_channel_time ON channel_snapshots(channel_id,captured_at);
