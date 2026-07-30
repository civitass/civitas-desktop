//! Text normalization and query expansion for improved FTS search.
//!
//! This module provides query-side improvements to full-text search recall
//! without changing English search semantics. It expands search queries to
//! catch compound words that OCR may have concatenated and provides CJK shadow
//! tokens for FTS indexes that need Chinese/Japanese/Korean substring recall.

use once_cell::sync::Lazy;
use regex::Regex;

// Pre-compiled regexes for minimal overhead
static CAMEL_CASE: Lazy<Regex> = Lazy::new(|| Regex::new(r"([a-z])([A-Z])").unwrap());
static NUM_TO_LETTER: Lazy<Regex> = Lazy::new(|| Regex::new(r"([0-9])([a-zA-Z])").unwrap());
static LETTER_TO_NUM: Lazy<Regex> = Lazy::new(|| Regex::new(r"([a-zA-Z])([0-9])").unwrap());

/// True for Han, Hiragana, Katakana, Hangul, and common CJK compatibility
/// blocks. This intentionally excludes Latin full-width punctuation; we only
/// switch to CJK behavior when the query/text contains CJK content.
#[inline]
pub fn is_cjk_char(ch: char) -> bool {
    matches!(
        ch as u32,
        0x3400..=0x4DBF  // CJK Unified Ideographs Extension A
            | 0x4E00..=0x9FFF  // CJK Unified Ideographs
            | 0xF900..=0xFAFF  // CJK Compatibility Ideographs
            | 0x3040..=0x309F  // Hiragana
            | 0x30A0..=0x30FF  // Katakana
            | 0x31F0..=0x31FF  // Katakana Phonetic Extensions
            | 0xAC00..=0xD7AF  // Hangul Syllables
            | 0x1100..=0x11FF  // Hangul Jamo
            | 0x3130..=0x318F  // Hangul Compatibility Jamo
            | 0x20000..=0x2A6DF // CJK Unified Ideographs Extension B
            | 0x2A700..=0x2B73F // Extension C
            | 0x2B740..=0x2B81F // Extension D
            | 0x2B820..=0x2CEAF // Extension E/F
            | 0x2CEB0..=0x2EBEF // Extension G/H
    )
}

/// True when text contains CJK characters.
#[inline]
pub fn contains_cjk(text: &str) -> bool {
    text.chars().any(is_cjk_char)
}

/// Remove OCR-inserted spaces between adjacent CJK characters while preserving
/// meaningful spaces between CJK and Latin/numeric words.
///
/// Windows OCR and some cross-platform OCR paths frequently emit Chinese text
/// as `项 目 进 度`. SQLite unicode61 then tokenizes that as unrelated
/// single-character terms, so searching `项目` fails. Normalizing to `项目进度`
/// preserves user-visible text while giving the index/query path a stable
/// string to tokenize into shadows.
pub fn normalize_cjk_ocr_spacing(text: &str) -> String {
    if !contains_cjk(text) || !text.chars().any(char::is_whitespace) {
        return text.to_string();
    }

    let chars: Vec<char> = text.chars().collect();
    let mut out = String::with_capacity(text.len());

    for (idx, ch) in chars.iter().copied().enumerate() {
        if ch.is_whitespace() {
            let prev = chars[..idx]
                .iter()
                .rev()
                .copied()
                .find(|c| !c.is_whitespace());
            let next = chars[idx + 1..]
                .iter()
                .copied()
                .find(|c| !c.is_whitespace());
            if prev.is_some_and(is_cjk_char) && next.is_some_and(is_cjk_char) {
                continue;
            }
        }
        out.push(ch);
    }

    out
}

fn normalize_for_cjk_tokens(text: &str) -> Vec<char> {
    normalize_cjk_ocr_spacing(text)
        .chars()
        .filter(|ch| {
            if ch.is_whitespace() {
                return false;
            }
            if is_cjk_char(*ch) {
                return true;
            }
            ch.is_ascii_alphanumeric()
        })
        .flat_map(|ch| ch.to_lowercase())
        .collect()
}

/// Generate stable CJK shadow tokens for FTS5 unicode61 indexes.
///
/// The returned string intentionally contains both unigrams and bigrams:
/// - unigrams let one-character names/entities remain findable;
/// - bigrams make normal Chinese substring searches (`项目`, `上海交通`) work
///   without relying on SQLite tokenizer language segmentation support.
///
/// ASCII letters/digits adjacent to CJK are included in the sequence so names
/// such as `N1项目` and `Unity云` get useful mixed-script bigrams.
pub fn cjk_shadow_tokens(text: &str) -> String {
    if !contains_cjk(text) {
        return String::new();
    }

    let chars = normalize_for_cjk_tokens(text);
    if chars.is_empty() {
        return String::new();
    }

    let mut tokens = Vec::with_capacity(chars.len().saturating_mul(2));
    for ch in &chars {
        tokens.push(ch.to_string());
    }
    for window in chars.windows(2) {
        tokens.push(window.iter().collect::<String>());
    }

    tokens.sort();
    tokens.dedup();
    tokens.join(" ")
}

/// Build text for CJK shadow columns without polluting user-visible content.
pub fn cjk_search_text(text: &str) -> String {
    cjk_shadow_tokens(text)
}

/// Construct an FTS5 MATCH expression for a CJK query against shadow-token
/// indexes. Returns `None` for non-CJK or empty queries.
pub fn cjk_fts5_query(query: &str) -> Option<String> {
    let shadow = cjk_shadow_tokens(query);
    if shadow.is_empty() {
        return None;
    }
    Some(
        shadow
            .split_whitespace()
            .map(|token| format!("\"{}\"", token.replace(['\\', '"'], "")))
            .collect::<Vec<_>>()
            .join(" "),
    )
}

fn quote_fts5_terms(query: &str) -> String {
    query
        .split_whitespace()
        .filter_map(|token| {
            let cleaned = token.replace(['\\', '"'], "");
            if cleaned.is_empty() {
                return None;
            }
            Some(format!("\"{}\"", cleaned))
        })
        .collect::<Vec<_>>()
        .join(" ")
}

/// Split compound words on camelCase and number boundaries.
///
/// Used internally for query expansion.
#[inline]
fn split_compound(text: &str) -> String {
    // Fast path: if no uppercase letters or digits, skip processing
    if !text
        .bytes()
        .any(|b| b.is_ascii_uppercase() || b.is_ascii_digit())
    {
        return text.to_string();
    }

    let result = CAMEL_CASE.replace_all(text, "$1 $2");
    let result = NUM_TO_LETTER.replace_all(&result, "$1 $2");
    let result = LETTER_TO_NUM.replace_all(&result, "$1 $2");
    result.into_owned()
}

/// Sanitize a query string for safe use in FTS5 MATCH expressions.
///
/// Wraps each whitespace-delimited token in double quotes so that
/// special characters (dots, parens, colons, etc.) are treated as
/// literal text rather than FTS5 operators.
///
/// # Example
/// ```
/// use civitas_db::text_normalizer::sanitize_fts5_query;
///
/// assert_eq!(sanitize_fts5_query("100.100.0.42"), r#""100.100.0.42""#);
/// assert_eq!(sanitize_fts5_query("hello world"), r#""hello" "world""#);
/// ```
pub fn sanitize_fts5_query(query: &str) -> String {
    let query = if contains_cjk(query) {
        normalize_cjk_ocr_spacing(query)
    } else {
        query.to_string()
    };

    let exact = quote_fts5_terms(&query);
    if !contains_cjk(&query) {
        return exact;
    }

    match (exact.is_empty(), cjk_fts5_query(&query)) {
        (true, _) => String::new(),
        (false, Some(shadow)) if shadow != exact => format!("({exact} OR {shadow})"),
        (false, _) => exact,
    }
}

/// Expand a search query to improve recall on compound words.
///
/// Takes a user query and returns an expanded FTS5 query that searches for:
/// 1. The original term (with prefix matching)
/// 2. Split parts of compound words (with prefix matching)
///
/// All tokens are quoted to safely handle special characters (dots, parens, etc.)
/// in FTS5.
///
/// This catches cases where OCR concatenated words like "ActivityPerformance"
/// when the user searches for "activity" or "performance".
///
/// # Example
/// ```
/// use civitas_db::text_normalizer::expand_search_query;
///
/// // Single word - quoted with prefix matching
/// assert_eq!(expand_search_query("test"), r#""test"*"#);
///
/// // Compound word - expands to catch parts
/// assert_eq!(expand_search_query("proStart"), r#"("proStart"* OR "pro"* OR "Start"*)"#);
/// ```
pub fn expand_search_query(query: &str) -> String {
    let query = query.trim();
    if query.is_empty() {
        return String::new();
    }

    if contains_cjk(query) {
        return sanitize_fts5_query(query);
    }

    // Process each word in the query
    let expanded_terms: Vec<String> = query
        .split_whitespace()
        .flat_map(|word| {
            let cleaned = word.replace(['\\', '"'], "");
            let split = split_compound(&cleaned);
            let parts: Vec<&str> = split.split_whitespace().collect();

            if parts.len() > 1 {
                // Word was split - include original and parts with prefix matching
                let mut terms = vec![format!("\"{}\"*", cleaned)];
                for part in parts {
                    if part.len() >= 2 {
                        // Only add parts with 2+ chars to avoid noise
                        terms.push(format!("\"{}\"*", part));
                    }
                }
                terms
            } else {
                // No split needed - just add quoted prefix matching
                vec![format!("\"{}\"*", cleaned)]
            }
        })
        .collect();

    if expanded_terms.len() == 1 {
        expanded_terms[0].clone()
    } else {
        format!("({})", expanded_terms.join(" OR "))
    }
}

/// Convert a column name and value into a safe FTS5 query string.
///
/// Example:
/// column="app_name", value="zoom.us" -> "app_name:\"zoom.us\""
/// column="app_name", value="foo bar" -> "app_name:\"foo\" app_name:\"bar\""
pub fn value_to_fts5_column_query(column: &str, value: &str) -> String {
    let value = if contains_cjk(value) {
        normalize_cjk_ocr_spacing(value)
    } else {
        value.to_string()
    };

    quote_fts5_terms(&value)
        .split_whitespace()
        .map(|token| format!("{}:{}", column, token))
        .collect::<Vec<_>>()
        .join(" ")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_split_compound_camel_case() {
        assert_eq!(split_compound("camelCase"), "camel Case");
        assert_eq!(split_compound("CamelCase"), "Camel Case");
        assert_eq!(
            split_compound("ActivityPerformance"),
            "Activity Performance"
        );
    }

    #[test]
    fn test_split_compound_numbers() {
        assert_eq!(split_compound("test123"), "test 123");
        assert_eq!(split_compound("123test"), "123 test");
        assert_eq!(split_compound("test123word"), "test 123 word");
    }

    #[test]
    fn test_split_compound_no_change() {
        assert_eq!(split_compound("hello"), "hello");
        assert_eq!(split_compound("hello world"), "hello world");
    }

    #[test]
    fn test_sanitize_fts5_simple() {
        assert_eq!(sanitize_fts5_query("hello"), r#""hello""#);
        assert_eq!(sanitize_fts5_query("hello world"), r#""hello" "world""#);
    }

    #[test]
    fn test_sanitize_fts5_dots() {
        assert_eq!(sanitize_fts5_query("100.100.0.42"), r#""100.100.0.42""#);
    }

    #[test]
    fn test_sanitize_fts5_special_chars() {
        assert_eq!(sanitize_fts5_query("foo(bar)"), r#""foo(bar)""#);
        assert_eq!(sanitize_fts5_query("C++"), r#""C++""#);
    }

    #[test]
    fn test_sanitize_fts5_strips_quotes() {
        assert_eq!(
            sanitize_fts5_query(r#"he said "hello""#),
            r#""he" "said" "hello""#
        );
    }

    #[test]
    fn test_sanitize_fts5_strips_backslashes() {
        assert_eq!(sanitize_fts5_query(r#"test\query"#), r#""testquery""#);
        assert_eq!(sanitize_fts5_query(r#"path\to\file"#), r#""pathtofile""#);
        assert_eq!(sanitize_fts5_query(r#"\"#), "");
        assert_eq!(sanitize_fts5_query(r#"hello\ world"#), r#""hello" "world""#);
        assert_eq!(sanitize_fts5_query(r#"test\"quoted""#), r#""testquoted""#);
    }

    #[test]
    fn test_sanitize_fts5_empty() {
        assert_eq!(sanitize_fts5_query(""), "");
        assert_eq!(sanitize_fts5_query("   "), "");
    }

    #[test]
    fn test_expand_simple_query() {
        assert_eq!(expand_search_query("test"), r#""test"*"#);
        assert_eq!(expand_search_query("hello"), r#""hello"*"#);
    }

    #[test]
    fn test_expand_compound_query() {
        assert_eq!(
            expand_search_query("proStart"),
            r#"("proStart"* OR "pro"* OR "Start"*)"#
        );
        assert_eq!(
            expand_search_query("ActivityPerformance"),
            r#"("ActivityPerformance"* OR "Activity"* OR "Performance"*)"#
        );
    }

    #[test]
    fn test_expand_number_boundary() {
        assert_eq!(
            expand_search_query("test123"),
            r#"("test123"* OR "test"* OR "123"*)"#
        );
    }

    #[test]
    fn test_expand_multi_word_query() {
        // Each word gets expanded independently
        assert_eq!(
            expand_search_query("hello world"),
            r#"("hello"* OR "world"*)"#
        );
    }

    #[test]
    fn test_expand_empty_query() {
        assert_eq!(expand_search_query(""), "");
        assert_eq!(expand_search_query("   "), "");
    }

    #[test]
    fn test_expand_filters_short_parts() {
        // Single char parts should be filtered out
        assert_eq!(expand_search_query("iPhone"), r#"("iPhone"* OR "Phone"*)"#);
    }

    #[test]
    fn test_expand_preserves_lowercase() {
        assert_eq!(expand_search_query("simple"), r#""simple"*"#);
    }

    #[test]
    fn test_expand_dots_in_query() {
        // IP addresses and dotted identifiers should be safely quoted
        assert_eq!(expand_search_query("100.100.0.42"), r#""100.100.0.42"*"#);
    }

    #[test]
    fn test_cjk_spacing_removes_only_inter_cjk_spaces() {
        assert_eq!(normalize_cjk_ocr_spacing("项 目 进 度"), "项目进度");
        assert_eq!(normalize_cjk_ocr_spacing("Unity 项 目 A"), "Unity 项目 A");
        assert_eq!(
            normalize_cjk_ocr_spacing("上海 Jiao Tong"),
            "上海 Jiao Tong"
        );
    }

    #[test]
    fn test_cjk_shadow_tokens_include_unigrams_and_bigrams() {
        let tokens = cjk_shadow_tokens("项 目 进 度");
        for expected in ["项", "目", "进", "度", "项目", "目进", "进度"] {
            assert!(
                tokens.split_whitespace().any(|token| token == expected),
                "missing token {expected} in {tokens}"
            );
        }
    }

    #[test]
    fn test_cjk_fts_query_is_quoted_and_safe() {
        assert_eq!(
            cjk_fts5_query("项目").as_deref(),
            Some(r#""目" "项" "项目""#)
        );
        assert!(cjk_fts5_query("hello").is_none());
    }

    #[test]
    fn test_cjk_sanitize_keeps_english_behavior_isolated() {
        assert_eq!(
            sanitize_fts5_query("项 目"),
            r#"("项目" OR "目" "项" "项目")"#
        );
        assert_eq!(
            expand_search_query("项 目"),
            r#"("项目" OR "目" "项" "项目")"#
        );
        assert_eq!(expand_search_query("simple"), r#""simple"*"#);
    }
}
