# Knowledge assertion provenance

Civitas stores every personal knowledge assertion with its source pointer,
confidence, attribution, bitemporal state, and a structured derivation trace.
The trace is local metadata: it explains how an assertion was produced without
copying a prompt, evidence body, provider response, endpoint, or credential.

## Stored contract

`kg_claims` carries the assertion and its derivation metadata in the same row.
That deliberate co-location prevents export, retention, correction, or deletion
from separating a fact from the record that explains it.

The structured fields record:

- selected provider family and provider-profile identifier;
- exact provider-qualified model ID;
- local Civitas runtime;
- versioned prompt and structured-output schema;
- extractor name and implementation version;
- derivation kind: model extraction, model abduction, deterministic logic,
  user authorship, import, or honestly unknown;
- evidence medium and bounded source-record count, never evidence content;
- validation status and bounded machine-readable quality flags;
- local inference-audit identifier and a non-content failure code, when
  applicable; and
- derivation time.

The local inference gateway returns a content-free receipt only after it has
durably completed the corresponding inference audit. Episode extraction,
decision abduction, and Scribe claims persist that receipt through the same
transaction as the claim. The selected profile's extraction model is used for
background Scribe/extraction requests when configured.

## Consumer trust surface

Every knowledge-graph response includes a privacy-safe `extraction` object
alongside confidence, source, date, and contradiction status. It includes the
provider, model, runtime, prompt/schema versions, extractor/version, evidence
classification, validation state, quality flags, and derivation time.

Internal provider-profile and inference-audit identifiers are not returned by
normal graph read APIs. The Ask source list shows a compact provider/model and
extractor version line. **Evidence → How this was derived** provides the full
non-sensitive trace using progressive disclosure.

Legacy rows are migrated without invented facts. Their known `extracted_by`
value becomes the model, while provider, prompt, and runtime remain explicitly
unknown and `legacy-metadata` remains a quality flag.

## Ownership, export, and deletion

The deterministic portable export includes these columns with `kg_claims`, plus
the separate metadata-only inference audit. Provider credentials, secret
references, prompts, evidence and response bodies remain excluded.

Assertion deletion removes the claim and its provenance atomically because
they are one row. Derived-data retention and full-library deletion have the
same property. An exported copy remains independently owned and must be
deleted separately.

## Verification

Focused regression coverage checks:

- rich provenance round-trips exactly;
- explicit review status sets the visible review flag without discarding the
  calibrated confidence;
- a low-confidence claim cannot be labelled accepted;
- assertion deletion cannot leave provenance behind;
- gateway receipts are percent-decoded without reading unrelated headers;
- the TypeScript response mirror contains every snake-case derivation field;
  and
- the consumer provenance line shows the provider, model, extractor and
  implementation version.

The publication knowledge-quality gate also requires complete provider, model,
runtime, prompt/schema and extractor versions for its synthetic assertions.
