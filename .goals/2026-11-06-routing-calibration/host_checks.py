"""Reproduce the reviewed numerical predicates without importing application dependencies."""
import ast, json, math, subprocess
from pathlib import Path
root=Path(__file__).resolve().parent
fg="/home/allen/project/repo/FG-CLIP"
text=subprocess.check_output(["git","-C",fg,"show","ed8b3cf:caption_tune/labo/paired_attribution.py"],text=True)
tree=ast.parse(text)
values={}
for n in tree.body:
    if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id in ["HTML_TOLERANCE","HTML_SLACK"] for t in n.targets):
        exec(compile(ast.Module(body=[n],type_ignores=[]),"<historical-source>","exec"),{"dict":dict},values)
tol,slack=values["HTML_TOLERANCE"],values["HTML_SLACK"]
boundaries={}
for k,v in tol.items():
    diff=v+slack/2
    assert diff>v and diff<=v+slack
    boundaries[k]={"declared":v,"difference":diff,"historical_accepts":diff<=v+slack,"locked_contract_accepts":diff<=v}
nan=float("nan")
assert max(0.0,nan)==0.0 and not(nan>1e-6)
result={"R2":boundaries,"R1":{"max_0_nan":max(0.0,nan),"nan_gt_tolerance":nan>1e-6,"finite":math.isfinite(nan),"limit":"Python scalar comparison/aggregation reproduction only, not a full digest-valid cache fixture or GPU execution."}}
(root/"host-check-results.json").write_text(json.dumps(result,indent=2,allow_nan=False)+"\n")
print(json.dumps(result,indent=2))
