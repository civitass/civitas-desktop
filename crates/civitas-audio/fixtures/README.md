# Synthetic audio evaluation fixtures

Civitas does not publish recordings, transcripts, or model weights as test
fixtures. Real voices and captured screen recordings are especially unsuitable
for a public source tree because consent, identity, and redistribution rights
cannot be inferred from a filename.

The `transcription_eval` example accepts a private, externally stored fixture
directory. Every manifest must make these machine-readable attestations:

```json
{
  "schema_version": 1,
  "synthetic_fixture": true,
  "contains_real_person_data": false,
  "fixture_license": "CC0-1.0",
  "engine": "parakeet",
  "max_average_wer": 0.35,
  "cases": [
    {
      "name": "synthetic_schedule",
      "audio_path": "synthetic_schedule.wav",
      "reference": "The generated example sentence belongs here.",
      "language": "en",
      "max_wer": 0.4
    }
  ]
}
```

Generate the audio from invented text and a synthetic voice whose terms permit
CC0 redistribution. Do not use meeting recordings, celebrity or employee
voices, customer data, production captures, voice clones, or text copied from a
real person's communications. Keep the manifest and its audio files in the
same external directory. Relative paths may not escape that directory.

Run the evaluator explicitly:

```bash
export CIVITAS_AUDIO_EVAL_MANIFEST=/absolute/external/path/manifest.json
cargo run -p civitas-audio --example transcription_eval \
  --features parakeet --release
```

The evaluator fails closed when the manifest or an audio path is inside the
repository checkout. It prints only case names, language tags, word-error-rate
metrics, and word counts—not references or generated transcripts. Review the
Parakeet source, license, size, and network behavior in
[`../../../docs/MODEL_CATALOG.md`](../../../docs/MODEL_CATALOG.md) before
allowing its first explicit download.
