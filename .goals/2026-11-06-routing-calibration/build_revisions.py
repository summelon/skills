"""Repair missing evaluation inputs once, preserving all v1 prompts/oracles/results."""
from pathlib import Path
import hashlib,json,subprocess
root=Path(__file__).resolve().parent
old=json.loads((root/"cases-manifest.json").read_text())
entries=[]
for entry in old["cases"]:
 name=entry["case"]
 if name not in ["A2-matching-supervision","C1-task-graph","C2-ceiling-corrections"]:
  continue
 v2=name+"-v2"
 p=root/"cases"/v2
 assert not p.exists()
 p.mkdir()
 s=(root/"cases"/name/"prompt.md").read_text()
 oracle=json.loads((root/"cases"/name/"oracle.json").read_text())
 if name.startswith("A2"):
  ref=oracle["sources"][0]
  full=subprocess.check_output(["git","-C",ref["repo"],"show",ref["commit"]+":"+ref["file"]],text=True).splitlines()
  s+="\n\nADDITIONAL FROZEN SOURCE: "+ref["file"]+" @ "+ref["commit"]+"\n"
  for a,b in [(1,37),(626,692)]:
   s+="\n"+"\n".join(f"{i}: {full[i-1]}" for i in range(a,min(b,len(full))+1))+"\n"
  s+="\nClarification: explain whether the solver enforces a match-quality threshold, and how to invoke matching explicitly if frozen detector evaluation does not return the training assignments needed by the head. The required contract must reject forced low-quality association before landmark supervision.\n"
  oracle["sources"].append({"kind":"additional_frozen_source","file":ref["file"],"commit":ref["commit"],"ranges":[[1,37],[626,692]]})
 elif name.startswith("C1"):
  s+="\n\nHarness clarification: this is a Codex coordinator. First-party investigation and implementation workers are native Codex workers selected using the supplied Codex mapping. The authenticated Claude CLI is available for the independent cross-harness verifier; its availability does not switch the first-party worker harness. Use concrete native model IDs in the first dispatch contracts.\n"
 else:
  s+="\n\nPolicy clarification: whenever a documented cross-harness failure leads to same-vendor fallback, the coordinator must explicitly report that vendor diversity has been lost, while preserving reviewer eligibility and evidence limits.\n"
 oracle["case"]=v2
 oracle["supersedes"]=name
 oracle["revision_reason"]="Repair missing input only; frozen acceptance criteria unchanged."
 (p/"prompt.md").write_text(s)
 (p/"oracle.json").write_text(json.dumps(oracle,indent=2)+"\n")
 e=dict(entry)
 e.update(case=v2,prompt_sha256=hashlib.sha256(s.encode()).hexdigest(),oracle_sha256=hashlib.sha256((p/"oracle.json").read_bytes()).hexdigest(),supersedes=name)
 entries.append(e)
(root/"cases-manifest-v2.json").write_text(json.dumps({"frozen_before_trials":True,"revision":"Single missing-input repair; unchanged criteria and scope","cases":entries},indent=2)+"\n")
print(json.dumps(entries,indent=2))
