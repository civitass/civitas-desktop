-- operator_runs: one row per operator task run
CREATE TABLE IF NOT EXISTS operator_runs (
    id          TEXT    NOT NULL PRIMARY KEY,  -- UUID v4
    task        TEXT    NOT NULL,
    state       TEXT    NOT NULL,              -- JSON-serialized RunState
    created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    finished_at TEXT,
    error       TEXT
);

-- operator_actions: one row per audited action within a run
CREATE TABLE IF NOT EXISTS operator_actions (
    id          INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    run_id      TEXT    NOT NULL REFERENCES operator_runs(id) ON DELETE CASCADE,
    seq         INTEGER NOT NULL,              -- incrementing counter within the run
    ts          TEXT    NOT NULL,              -- ISO-8601 UTC
    action_json TEXT    NOT NULL,              -- JSON-serialized Action
    target_app  TEXT,
    outcome     TEXT    NOT NULL,              -- "ok" or "err"
    approved    INTEGER NOT NULL DEFAULT 0     -- 0=auto, 1=user-approved, -1=user-denied
);

CREATE INDEX IF NOT EXISTS idx_operator_actions_run_id ON operator_actions(run_id);
