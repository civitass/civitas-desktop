-- Episode mining persistence tables.
-- semantic_actions: normalised user actions produced by the mining pipeline.
-- episodes: threaded work episodes assembled from segments.
-- episode_segments: boundary-scored spans that make up an episode.
-- mining_state: simple key/value store for persisting cursor and other runtime
--   state across restarts.

-- advisory first_event_id / last_event_id reference ui_events but carry no FK
-- because retention may purge those rows independently.

CREATE TABLE IF NOT EXISTS semantic_actions (
    id               INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    episode_id       INTEGER REFERENCES episodes(id) ON DELETE SET NULL,
    ts_start         TEXT NOT NULL,
    ts_end           TEXT NOT NULL,
    verb             TEXT NOT NULL,
    object           TEXT,
    app_name         TEXT,
    window_title     TEXT,
    browser_url      TEXT,
    document_path    TEXT,
    artifacts        TEXT NOT NULL DEFAULT '[]',
    event_count      INTEGER NOT NULL DEFAULT 1,
    first_event_id   INTEGER,
    last_event_id    INTEGER,
    text_sample      TEXT,
    mining_version   INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS episodes (
    id                   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    started_at           TEXT NOT NULL,
    ended_at             TEXT,
    status               TEXT NOT NULL CHECK (status IN ('open', 'closed')),
    boundary_confidence  REAL,
    apps                 TEXT NOT NULL DEFAULT '[]',
    artifacts            TEXT NOT NULL DEFAULT '[]',
    action_count         INTEGER NOT NULL DEFAULT 0,
    summary              TEXT,
    intent               TEXT,
    outcome              TEXT CHECK (
                             outcome IN ('done', 'abandoned', 'handed_off', 'interrupted')
                             OR outcome IS NULL
                         ),
    summary_model        TEXT,
    summary_attempts     INTEGER NOT NULL DEFAULT 0,
    label_source         TEXT NOT NULL DEFAULT 'miner'
                             CHECK (label_source IN ('miner', 'user')),
    mining_version       INTEGER NOT NULL,
    created_at           TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at           TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE IF NOT EXISTS episode_segments (
    id                  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    episode_id          INTEGER NOT NULL REFERENCES episodes(id) ON DELETE CASCADE,
    seg_index           INTEGER NOT NULL,
    started_at          TEXT NOT NULL,
    ended_at            TEXT NOT NULL,
    boundary_confidence REAL
);

CREATE TABLE IF NOT EXISTS mining_state (
    key        TEXT NOT NULL PRIMARY KEY,
    value      TEXT NOT NULL,
    updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_episodes_started_at         ON episodes(started_at);
CREATE INDEX IF NOT EXISTS idx_episodes_status             ON episodes(status);
CREATE INDEX IF NOT EXISTS idx_semantic_actions_episode_id ON semantic_actions(episode_id);
CREATE INDEX IF NOT EXISTS idx_semantic_actions_ts_start   ON semantic_actions(ts_start);
CREATE INDEX IF NOT EXISTS idx_episode_segments_episode_id ON episode_segments(episode_id, seg_index);
