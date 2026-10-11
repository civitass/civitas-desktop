# Dependency security maintenance

The release gate evaluates every tracked Bun lockfile and both Rust lockfiles.
Run it with the pinned tools before publishing:

```bash
node scripts/audit-js-security.mjs
node scripts/audit-rust-security.mjs
```

## October 2026 JavaScript updates

The desktop uses Next.js and its ESLint configuration at 15.5.27, DOMPurify
3.4.16, ProseMirror View 1.42.3, KaTeX 0.18.2, markdown-it 14.3.1, sharp
0.35.5, PostCSS Selector Parser 7.1.6, source-map-js 1.2.2, brace-expansion
5.0.12, and undici 7.29.1. Argparse 2.0.1 removes the obsolete sprintf-js
dependency. Rendering, editor, build, and test coverage must pass after these
updates; a clean advisory report alone does not establish compatibility.

The MCP bridge resolves MCP SDK 1.32.1, fast-uri 3.1.8, Hono 4.13.13,
ip-address 10.7.3, proxy-addr 2.0.8, and source-map-js 1.2.2. The separately
consented assistant runtime remains at pi 0.82.1 with brace-expansion 5.0.12
and undici 8.10.2. These updates add no runtime destination or permission.

## Reviewed local patches

Two advisories have no patched npm release as of this review. Upstream package
names and versions remain intact so external scanners continue to identify
them. Civitas applies tracked Bun patches during frozen installation:

| Package | Use | Remediation |
| --- | --- | --- |
| braces 3.0.3 | Desktop build and development tooling | Bound parse nesting, recursive AST walkers, and parent traversal, including callers that supply ASTs directly. Excessive nesting raises a validation error before stack exhaustion. |
| node-forge 1.4.0 | MCP bundle development tooling; absent from its production dependency graph | Reject extra children in the nested RSA PKCS#1 v1.5 DigestAlgorithm sequence as well as the outer DigestInfo. |

References: [braces advisory](https://github.com/advisories/GHSA-vfj7-8cjw-p6xm),
[node-forge advisory](https://github.com/advisories/GHSA-86w9-cpqp-85rv), and
[upstream RSA correction](https://github.com/digitalbazaar/forge/pull/1152).

The repository gate requires the exact reviewed SHA-256 of each patch, matching
declarations in both package manifest and lockfile, the reviewed version for
every locked occurrence, and passing behavioral regressions against the
installed packages. Only those exact package/advisory pairs can be classified
as locally remediated. Missing patches, changed bytes or versions, additional
advisories, malformed scanner output, and failed regressions block release.
`bun audit` run directly still reports these upstream advisories; this is
expected and is not represented as a vulnerability-free dependency graph.

Replace a patch with an upstream fixed release when available, retaining the
regressions. Review the complete lockfile diff and license metadata. Do not
rename packages, fabricate versions, remove integrity checks, or broadly ignore
a package to make the gate pass. See [third-party notices](../THIRD_PARTY_NOTICES.md)
for licenses and [release verification](RELEASE_VERIFICATION.md) for the full
publication boundary.
