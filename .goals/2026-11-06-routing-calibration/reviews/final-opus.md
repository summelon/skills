**ACCEPT**

I checked this statically and ran nothing. Items 2b and 4 are partly or fully open, but neither is substantive:

1. **Client-configured wording:** fixed. Deviations now says "client-configured Astra/high".
2. **Grade source and scripts:** partly fixed. `adjudication.json` is now named as the grade source, with `results.json` as the copy.
   - However, the claim that `verification.md` names all regeneration scripts is inaccurate. Its Reproduction section lists only `build_cases.py`. `build_revisions.py` and `build_v3.py` appear only in report step 5. Correct either the closure record or the file.
3. **Fresh `--output-dir`:** fixed, in both report step 4 and `verification.md`.
4. **Pass labels:** fixed. Each lane's verdict now comes from its criterion grades.
   - Minor: `write_report.py` still reads `results.json` from the study root and writes `report.md` there. A reproduction using a fresh `--output-dir` would rebuild the report from the original results.
5. **Limited-input dispositions:** fixed. `limited_input_dispositions` records one per run for all 8 non-selected runs (20 − 12). An unknown case raises an error rather than passing silently.

No numbers, inputs, grades or recommendations changed. G6 can be recorded as passed. This does not authorize promotion, default changes or commits.
