"""Regenerate the exact catalog-complete C1-v3 fixture; verify existing frozen bytes."""
from pathlib import Path
import hashlib,json
root=Path(__file__).resolve().parent
source=root/"cases/C1-task-graph-v2"
target=root/"cases/C1-task-graph-v3"
text=(source/"prompt.md").read_text()+"""
Available native model catalog for this evaluation (authoritative, supplied context):
- Sol means gpt-6.1-sol, supported worker efforts low, medium, high.
- Luna means gpt-6-luna, supported worker efforts low, high, xhigh under these routes.
- Astra means gpt-6-astra; it is not authorized for first-party analysis or implementation in this scenario.
- Cross-harness Opus verifier is claude-opus-5-5, high, via the authenticated Claude CLI.
No model-ID lookup or assumption is needed. Use the supplied catalog and authorized ceiling.
"""
o=json.loads((source/"oracle.json").read_text())
o.update(case="C1-task-graph-v3",supersedes="C1-task-graph-v2",revision_reason="Supply the concrete model catalog required by v2; acceptance criteria remain unchanged.")
for name,body in [("prompt.md",text),("oracle.json",json.dumps(o,indent=2)+"\n")]:
 p=target/name
 if p.exists(): assert p.read_text()==body, f"{name}: frozen bytes changed"
 else:
  target.mkdir(exist_ok=True)
  p.write_text(body)
entry=next(x for x in json.loads((root/"cases-manifest-v2.json").read_text())["cases"] if x["case"]=="C1-task-graph-v2")
e=dict(entry,case=o["case"],supersedes=o["supersedes"],prompt_sha256=hashlib.sha256(text.encode()).hexdigest(),oracle_sha256=hashlib.sha256((target/"oracle.json").read_bytes()).hexdigest())
body=json.dumps({"frozen_before_trials":True,"revision":"Explicit catalog supplied; unchanged acceptance criteria. No more fixture revisions planned.","cases":[e]},indent=2)+"\n"
p=root/"cases-manifest-v3.json"
if p.exists(): assert p.read_text()==body,"v3 manifest changed"
else: p.write_text(body)
print("C1-v3 prompt, oracle and manifest reproduce exactly.")
