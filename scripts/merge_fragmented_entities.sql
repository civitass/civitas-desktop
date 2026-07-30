-- merge_fragmented_entities.sql
--
-- One-time migration that merges graph_nodes fragmented by synonym entity_key
-- prefixes into a single canonical node per real-world entity.
--
-- ROOT CAUSE (fixed in scribe.rs):
--   The Scribe LLM was allowed to emit any string for the entity `kind` field
--   (codebase/repo/app/project/…), so the same entity ("civitas") produced
--   different entity_keys and therefore different graph_nodes:
--     codebase:civitas, project:civitas, repo:civitas, app:civitas (→ 4 nodes)
--   find_or_create_node deduplicates ONLY on exact entity_key match, so all four
--   existed independently with separate occurrence counts and edge links.
--
-- WHAT THIS SCRIPT DOES:
--   For each group of entity-kind graph_nodes that share the same label
--   (case-insensitive) but have different entity_key prefixes, it picks one
--   canonical node (lowest id, i.e. oldest), merges occurrences from all
--   duplicates into it, repoints all graph_edges (from_node and to_node) to the
--   winner, then deletes the losers.
--
-- HOW TO RUN:
--   Stop the civitas engine first (the app must NOT be running):
--     pkill -f civitas-app
--   Then apply against the live database:
--     sqlite3 ~/.civitas/db.sqlite < scripts/merge_fragmented_entities.sql
--   Restart the engine afterwards.
--
-- IDEMPOTENCY:
--   The script is safe to re-run. After the first run there are no duplicate
--   (label, scope) groups left among entity-kind nodes, so the UPDATE / DELETE
--   steps find zero rows and are no-ops.
--
-- SCOPE: only graph_nodes with kind = 'entity' and a non-NULL entity_key.
--   Trigger-context (kind='context') and action (kind='action') nodes are not
--   touched.

-- ── Step 1: build a mapping table of (loser_id → winner_id) ─────────────────
--
-- Winner = the node with the lowest id in each (lower(label), scope) group,
-- among entity-kind nodes that have duplicate labels.

CREATE TEMP TABLE IF NOT EXISTS _entity_merge_map AS
SELECT
    dup.id         AS loser_id,
    winner.id      AS winner_id,
    winner.entity_key AS winner_key,
    winner.occurrences AS winner_occ,
    dup.occurrences    AS loser_occ
FROM graph_nodes dup
JOIN (
    -- For each (lower(label), scope) group with 2+ entity members,
    -- pick the survivor (lowest id).
    SELECT
        lower(label) AS lbl,
        scope,
        min(id)      AS id
    FROM graph_nodes
    WHERE kind = 'entity'
      AND entity_key IS NOT NULL
    GROUP BY lower(label), scope
    HAVING count(*) > 1
) winner_grp ON lower(dup.label) = winner_grp.lbl
            AND dup.scope        = winner_grp.scope
JOIN graph_nodes winner ON winner.id = winner_grp.id
WHERE dup.kind = 'entity'
  AND dup.entity_key IS NOT NULL
  AND dup.id != winner.id;

-- ── Step 2: accumulate occurrences on the winners ──────────────────────────

UPDATE graph_nodes
SET    occurrences = occurrences + (
    SELECT COALESCE(sum(loser_occ), 0)
    FROM   _entity_merge_map
    WHERE  winner_id = graph_nodes.id
)
WHERE  id IN (SELECT winner_id FROM _entity_merge_map);

-- ── Step 3: repoint graph_edges — from_node ────────────────────────────────

UPDATE graph_edges
SET    from_node = (
    SELECT winner_id
    FROM   _entity_merge_map
    WHERE  loser_id = graph_edges.from_node
)
WHERE  from_node IN (SELECT loser_id FROM _entity_merge_map);

-- ── Step 4: repoint graph_edges — to_node ──────────────────────────────────

UPDATE graph_edges
SET    to_node = (
    SELECT winner_id
    FROM   _entity_merge_map
    WHERE  loser_id = graph_edges.to_node
)
WHERE  to_node IN (SELECT loser_id FROM _entity_merge_map);

-- ── Step 5: collapse duplicate edges that now share the same (from,to,relation,scope)
--
-- After repointing, two formerly-separate edges may now point to the same pair.
-- Merge by keeping the survivor (lowest id) and summing weight/occurrences.

UPDATE graph_edges AS survivor
SET
    weight      = weight + (
        SELECT COALESCE(sum(dup.weight), 0)
        FROM   graph_edges dup
        WHERE  dup.from_node = survivor.from_node
          AND  dup.to_node   = survivor.to_node
          AND  dup.relation  = survivor.relation
          AND  dup.scope     = survivor.scope
          AND  dup.id > survivor.id
    ),
    occurrences = occurrences + (
        SELECT COALESCE(sum(dup.occurrences), 0)
        FROM   graph_edges dup
        WHERE  dup.from_node = survivor.from_node
          AND  dup.to_node   = survivor.to_node
          AND  dup.relation  = survivor.relation
          AND  dup.scope     = survivor.scope
          AND  dup.id > survivor.id
    )
WHERE  id IN (
    SELECT min(id)
    FROM   graph_edges
    GROUP  BY from_node, to_node, relation, scope
    HAVING count(*) > 1
);

DELETE FROM graph_edges
WHERE id NOT IN (
    SELECT min(id)
    FROM   graph_edges
    GROUP  BY from_node, to_node, relation, scope
);

-- ── Step 6: delete loser nodes ─────────────────────────────────────────────

DELETE FROM graph_nodes
WHERE  id IN (SELECT loser_id FROM _entity_merge_map);

-- ── Step 7: clean up temp table ────────────────────────────────────────────

DROP TABLE IF EXISTS _entity_merge_map;

-- ── Verification query (informational — uncomment to inspect after running) ──
-- SELECT kind, lower(label) AS lbl, scope, count(*) AS n
-- FROM   graph_nodes
-- WHERE  kind = 'entity'
-- GROUP  BY kind, lbl, scope
-- HAVING n > 1;
-- Expected: zero rows after a successful run.
