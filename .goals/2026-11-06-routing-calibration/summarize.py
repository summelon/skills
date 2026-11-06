"""Validate run provenance and aggregate already adjudicated pilot evidence."""
from pathlib import Path
import argparse,hashlib,json
ROOT=Path(__file__).resolve().parent
parser=argparse.ArgumentParser()
parser.add_argument('--runs-dir',type=Path,default=ROOT/'runs')
parser.add_argument('--output-dir',type=Path,default=ROOT)
parser.add_argument('--adjudication',type=Path,default=ROOT/'adjudication.json')
args=parser.parse_args()
RUNS=args.runs_dir.resolve()
OUTPUT=args.output_dir.resolve()
OUTPUT.mkdir(parents=True,exist_ok=True)
ADJ=json.loads(args.adjudication.read_text())
selected=["A1-proposal-supervision","A2-matching-supervision-v2","R1-cache-validation","R2-recorded-tolerance","C1-task-graph-v3","C2-ceiling-corrections-v2"]
entries={}
for fn in ["cases-manifest.json","cases-manifest-v2.json","cases-manifest-v3.json"]:
 for e in json.loads((ROOT/fn).read_text())["cases"]:
  entries[e["case"]]=e
all_runs=[]
for path in sorted(RUNS.glob("*/metadata.json")):
 d=json.loads(path.read_text())
 assert d["exit_code"]==0 and not d["errors"] and not d["unexpected_items"],path
 assert d["input_sha256"]==entries[d["case"]]["prompt_sha256"],path
 models=d["normalized_session_meta"]["models"]
 assert models=={d["requested_model"]:[d["requested_effort"]]},(path,models)
 d["configured_model_verified"]=True
 d["words"]=len((path.parent/"answer.md").read_text().split())
 all_runs.append(d)
# Restore versioned summaries deterministically from their per-run records.
for version in ["","-v2","-v3"]:
 names={e["case"] for e in json.loads((ROOT/f"cases-manifest{version}.json").read_text())["cases"]}
 (OUTPUT/f"run-summary{version}.json").write_text(json.dumps([d for d in all_runs if d["case"] in names],indent=2)+"\n")

rows=[]
for name in selected:
 by={d["lane"]:d for d in all_runs if d["case"]==name}
 oracle=json.loads((ROOT/"cases"/name/"oracle.json").read_text())
 grade=ADJ['cases'][name]
 assert [x["id"] for x in oracle["criteria"]]==[x["id"] for x in grade["criteria"]]
 for lane in ['control','candidate']:
  answer=RUNS/f'{name}--{lane}'/'answer.md'
  assert hashlib.sha256(answer.read_bytes()).hexdigest()==grade['answer_sha256'][lane],f'{name}/{lane}: answer changed; new semantic adjudication required'
 row={"case":name,"category":entries[name]["category"],"input_sha256":entries[name]["prompt_sha256"],"criteria":grade["criteria"],"grading":"Source-based semantic adjudication bound to exact answer hashes in adjudication.json; summarize.py only validates and aggregates these existing judgments.","control":by["control"],"candidate":by["candidate"],"false_accepts":grade["false_accepts"],"model_induced_followups":grade["model_induced_followups"]}
 if row["category"]=="coordinator":
  for lane in ["control","candidate"]:
   json.loads((RUNS/f"{name}--{lane}"/"answer.md").read_text())
 for lane in ["control","candidate"]:
  assert by[lane]["words"]<=650,(name,lane,by[lane]["words"])
 rows.append(row)
def total(data):
 out={}
 for lane in ["control","candidate"]:
  ds=[r[lane] for r in data]
  usage={k:sum(u.get(k,0) for d in ds for u in d["usage"]) for k in ["input_tokens","cached_input_tokens","cache_write_input_tokens","output_tokens","reasoning_output_tokens"]}
  out[lane]={"elapsed_seconds_sum":round(sum(d["elapsed_seconds"] for d in ds),3),"usage":usage}
 return out
disposition_by_case={
 "A2-matching-supervision":"Limited input: solver source and explicit frozen-eval invocation requirement omitted; superseded by v2.",
 "C1-task-graph":"Limited input: first-party harness unspecified; superseded by harness-specific versions.",
 "C1-task-graph-v2":"Limited input: concrete model catalog omitted; both models returned a missing-input question; superseded by v3.",
 "C2-ceiling-corrections":"Limited input: lost-vendor-diversity reporting rule omitted; superseded by v2."
}
limited_dispositions=[{"run":d["case"]+"--"+d["lane"],"disposition":disposition_by_case[d["case"]]} for d in all_runs if d["case"] not in selected]
report={"limited_input_dispositions":limited_dispositions,"selected_cases":selected,"quality":{"control_passed":sum(all(x["control"]=="pass" for x in r["criteria"]) for r in rows),"candidate_passed":sum(all(x["candidate"]=="pass" for x in r["criteria"]) for r in rows),"material_criteria_per_lane":sum(len(r["criteria"]) for r in rows),"false_accepts":sum(r["false_accepts"] for r in rows)},"categories":{c:total([r for r in rows if r["category"]==c]) for c in ["analysis","review","coordinator"]},"selected_totals":total(rows),"all_trial_count":len(all_runs),"limited_input_trials":[d["case"]+"--"+d["lane"] for d in all_runs if d["case"] not in selected],"all_trial_model_seconds_sum":round(sum(d["elapsed_seconds"] for d in all_runs),3),"all_trial_usage":{k:sum(u.get(k,0) for d in all_runs for u in d["usage"]) for k in ["input_tokens","cached_input_tokens","output_tokens","reasoning_output_tokens"]},"cases":rows,"limits":["Six guided supplied-text cases, one final pair per case; rubric conclusions overlap prompt instructions. No blind-discovery, statistical equivalence or default-replacement claim.","Source excerpts and reconstructed contracts; no replay of original encrypted contracts.","Coordinator tests are synthetic planning/fixed-digest decisions, not actual multi-agent execution.","No full application/training/GPU tests, real model upgrade, premium authorization transition, or broad concurrency/security/migration benchmark.","Concurrency=3; provider latency and cache warmth vary. Per-response elapsed sums exclude grading and real task implementation/repair.","Tokens and cache hits are measured; subscription quota, actual credits and monetary costs are not measured. Reasoning tokens are included in output tokens, not added again.","Limited-input trial outputs and their costs are preserved and counted dynamically; they are not independent quality replications. Version summaries are regenerated from per-run metadata, not immutable original runner emissions."]}
(OUTPUT/"results.json").write_text(json.dumps(report,indent=2)+"\n")
print(json.dumps({k:report[k] for k in ["quality","categories","all_trial_count","all_trial_model_seconds_sum","all_trial_usage"]},indent=2))
