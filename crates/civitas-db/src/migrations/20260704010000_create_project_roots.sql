-- Local selected project-root memory (P5).
--
-- This stores only user-selected roots and bounded, searchable file evidence.
-- It does not crawl the home directory and does not upload raw files to cloud.

CREATE TABLE IF NOT EXISTS project_roots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    safe_display_path TEXT NOT NULL,
    scope TEXT NOT NULL DEFAULT 'user',
    status TEXT NOT NULL DEFAULT 'active',
    include_patterns TEXT NOT NULL DEFAULT '[]',
    exclude_patterns TEXT NOT NULL DEFAULT '[]',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_indexed_at TIMESTAMP,
    last_error TEXT,
    file_count INTEGER NOT NULL DEFAULT 0,
    indexed_file_count INTEGER NOT NULL DEFAULT 0,
    skipped_file_count INTEGER NOT NULL DEFAULT 0,
    error_file_count INTEGER NOT NULL DEFAULT 0,
    deleted_file_count INTEGER NOT NULL DEFAULT 0,
    total_bytes INTEGER NOT NULL DEFAULT 0,
    indexed_bytes INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_project_roots_status ON project_roots(status);
CREATE INDEX IF NOT EXISTS idx_project_roots_updated_at ON project_roots(updated_at DESC);

CREATE TABLE IF NOT EXISTS project_files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    root_id INTEGER NOT NULL REFERENCES project_roots(id) ON DELETE CASCADE,
    relative_path TEXT NOT NULL,
    relative_path_folded TEXT NOT NULL,
    safe_display_path TEXT NOT NULL,
    name TEXT NOT NULL,
    extension TEXT,
    kind TEXT NOT NULL,
    size_bytes INTEGER NOT NULL DEFAULT 0,
    modified_at TIMESTAMP,
    indexed_at TIMESTAMP,
    stable_file_id TEXT NOT NULL,
    content_hash TEXT,
    text_content TEXT,
    text_preview TEXT,
    cjk_search_text TEXT,
    status TEXT NOT NULL DEFAULT 'indexed',
    skip_reason TEXT,
    error TEXT,
    is_binary INTEGER NOT NULL DEFAULT 0,
    is_placeholder INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(root_id, relative_path_folded)
);

CREATE INDEX IF NOT EXISTS idx_project_files_root_status ON project_files(root_id, status);
CREATE INDEX IF NOT EXISTS idx_project_files_stable_file_id ON project_files(stable_file_id);
CREATE INDEX IF NOT EXISTS idx_project_files_updated_at ON project_files(updated_at DESC);

CREATE VIRTUAL TABLE IF NOT EXISTS project_files_fts USING fts5(
    relative_path,
    safe_display_path,
    name,
    extension,
    text_content,
    cjk_search_text,
    content='project_files',
    content_rowid='id',
    tokenize='unicode61'
);

CREATE TRIGGER IF NOT EXISTS project_files_ai AFTER INSERT ON project_files BEGIN
    INSERT INTO project_files_fts(rowid, relative_path, safe_display_path, name, extension, text_content, cjk_search_text)
    VALUES (
        new.id,
        COALESCE(new.relative_path, ''),
        COALESCE(new.safe_display_path, ''),
        COALESCE(new.name, ''),
        COALESCE(new.extension, ''),
        COALESCE(new.text_content, ''),
        COALESCE(new.cjk_search_text, '')
    );
END;

CREATE TRIGGER IF NOT EXISTS project_files_ad AFTER DELETE ON project_files BEGIN
    INSERT INTO project_files_fts(project_files_fts, rowid, relative_path, safe_display_path, name, extension, text_content, cjk_search_text)
    VALUES ('delete', old.id, old.relative_path, old.safe_display_path, old.name, old.extension, COALESCE(old.text_content, ''), COALESCE(old.cjk_search_text, ''));
END;

CREATE TRIGGER IF NOT EXISTS project_files_au AFTER UPDATE ON project_files BEGIN
    INSERT INTO project_files_fts(project_files_fts, rowid, relative_path, safe_display_path, name, extension, text_content, cjk_search_text)
    VALUES ('delete', old.id, old.relative_path, old.safe_display_path, old.name, old.extension, COALESCE(old.text_content, ''), COALESCE(old.cjk_search_text, ''));
    INSERT INTO project_files_fts(rowid, relative_path, safe_display_path, name, extension, text_content, cjk_search_text)
    VALUES (
        new.id,
        COALESCE(new.relative_path, ''),
        COALESCE(new.safe_display_path, ''),
        COALESCE(new.name, ''),
        COALESCE(new.extension, ''),
        COALESCE(new.text_content, ''),
        COALESCE(new.cjk_search_text, '')
    );
END;
