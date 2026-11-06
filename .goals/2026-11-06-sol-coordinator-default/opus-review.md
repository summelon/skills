**Verdict: ACCEPT.** Both material findings are resolved, and I found no new ones.

**Monotonicity and scope by case**

| Session | Ceiling | Check |
| --- | --- | --- |
| Sol/high coordinator | Astra/high: T2 up to high; T0/T1 uncapped | Matches the previous Astra/high profile |
| Sol/xhigh coordinator | Same, via "high or above" | Raising effort no longer lowers the ceiling. It is a superset of the ordinary Sol/xhigh ceiling, since T1 stays uncapped below T2. |
| Ordinary Sol/high | T1/high | Excluded by "outside the coordinator role" |
| Sol/medium coordinator | Ordinary T1/medium; T2 ineligible | Below high, so weaker as expected. It needs an explicit override, since the profile is high, and "assume high" covers unseen effort. |
| Luna/xhigh worker under the coordinator | Eligible | "Lower tiers retain their existing effort choices" preserves T0's up step |
| Astra/xhigh session | T3 admitted, unchanged | No Sol coordinator reaches T3, and an Astra relaunch is still the only way up |

**Observability:** the trigger now uses facts the session can see: model, effort, and that it is acting under the coordinator skill. The `-p` profile no longer matters. `/coordinator` matches the adapter's `/model-routing` notation, so it reads as the repo's generic skill reference. That is acceptable.

**Precedence:** SKILL.md's new lead sentence correctly routes to this exception. It is inert for Claude Code, which defines no coordinator ceiling.

**Unchanged and confirmed:** the tier table, examples, verifier rules, cross-harness command and T3 thresholds. There is no worker promotion, reviewer substitution, or benchmark or savings claim. The template and adapter agree on `gpt-6.1-sol`/`high`, and the TOML still has no `developer_instructions`.

**Optional, non-blocking:** you could add "if you cannot tell whether you are coordinating, use the ordinary ceiling."
