"""Execute frozen paired supplied-text trials; outputs and metadata stay goal-owned."""
import argparse, asyncio, hashlib, json, os, subprocess, tempfile, time
from pathlib import Path

ROOT=Path(__file__).resolve().parent
MANIFEST=json.loads((ROOT/"cases-manifest.json").read_text())
OUT=ROOT/"runs"
OUT.mkdir(exist_ok=True)

async def one(case, lane, semaphore):
    async with semaphore:
        model="gpt-6-astra" if lane=="control" else "gpt-6.1-sol"
        effort="high" if lane=="control" else case["candidate_effort"]
        run=OUT/f"{case['case']}--{lane}"
        if (run/"metadata.json").exists():
            raise RuntimeError(f"Refusing to overwrite run {run}")
        run.mkdir()
        prompt=(ROOT/"cases"/case["case"]/"prompt.md").read_bytes()
        assert hashlib.sha256(prompt).hexdigest()==case["prompt_sha256"]
        scratch=Path(tempfile.mkdtemp(prefix="routing-trial-"))
        cmd=["codex","exec","--ignore-user-config","--ignore-rules","--skip-git-repo-check","--sandbox","read-only","--json","-C",str(scratch),"-m",model,"-c",f'model_reasoning_effort="{effort}"',"-c",'model_verbosity="low"',"-c","agents.enabled=false","-o",str(run/"answer.md"),"-"]
        meta={"case":case["case"],"lane":lane,"category":case["category"],"requested_model":model,"requested_effort":effort,"input_sha256":case["prompt_sha256"],"command":cmd,"cwd":str(scratch),"tools_policy":"supplied text; no tools by contract; unexpected tool use invalidates trial","fresh_context":True,"concurrency_cap":3,"start_utc":time.strftime("%Y-%m-%dT%H:%M:%SZ",time.gmtime())}
        start=time.monotonic()
        with (run/"events.jsonl").open("wb") as stdout, (run/"stderr.txt").open("wb") as stderr:
            p=await asyncio.create_subprocess_exec(*cmd,stdin=asyncio.subprocess.PIPE,stdout=stdout,stderr=stderr)
            try:
                await asyncio.wait_for(p.communicate(prompt),timeout=900)
                meta["exit_code"]=p.returncode
            except asyncio.TimeoutError:
                p.kill()
                await p.wait()
                meta["exit_code"]=124
                meta["timeout_seconds"]=900
        meta["elapsed_seconds"]=round(time.monotonic()-start,3)
        meta["end_utc"]=time.strftime("%Y-%m-%dT%H:%M:%SZ",time.gmtime())
        events=[]
        for line in (run/"events.jsonl").read_text().splitlines():
            try: events.append(json.loads(line))
            except json.JSONDecodeError: pass
        meta["events_count"]=len(events)
        meta["usage"]=[e.get("usage") for e in events if e.get("type")=="turn.completed"]
        meta["errors"]=[e for e in events if e.get("type") in ["error","turn.failed"]]
        meta["thread_id"]=next((e.get("thread_id") for e in events if e.get("type")=="thread.started"),None)
        meta["unexpected_items"]=[e.get("item",{}).get("type") for e in events if e.get("type")=="item.completed" and e.get("item",{}).get("type") not in ["agent_message","reasoning"]]
        meta["requested_model_resolved"]="not independently exposed by exec events"
        # Use the repository's normalized transcript reader to record configured runtime model/effort.
        # Do not parse user session JSONL directly or infer model identity from the answer.
        if meta["thread_id"]:
            helper=ROOT.parents[1]/"skills/engineering/skill-retro/scripts/runs.py"
            got=subprocess.run(["python3",str(helper),"show",meta["thread_id"],"--json","--max-events","1"],capture_output=True,text=True)
            if got.returncode==0:
                normalized=json.loads(got.stdout)
                meta["normalized_session_meta"]=normalized.get("meta")
                (run/"normalized-session.json").write_text(got.stdout)
        (run/"metadata.json").write_text(json.dumps(meta,indent=2)+"\n")
        print(json.dumps({k:meta[k] for k in ["case","lane","requested_model","requested_effort","exit_code","elapsed_seconds","usage","errors","unexpected_items"]}),flush=True)
        return meta

async def main(only, manifest, run_root):
    global OUT
    if run_root:
        OUT=Path(run_root).resolve()
        OUT.mkdir(parents=True,exist_ok=True)
    cases=json.loads((ROOT/manifest).read_text())
    sem=asyncio.Semaphore(3)
    jobs=[]
    for i,case in enumerate(cases["cases"]):
        if only and case["case"] not in only: continue
        for lane in (["control","candidate"] if i%2==0 else ["candidate","control"]):
            jobs.append(one(case,lane,sem))
    results=await asyncio.gather(*jobs)
    summary_name=Path(manifest).name.replace("cases-manifest","run-summary")
    (OUT/summary_name).write_text(json.dumps(results,indent=2)+"\n")

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--only",nargs="*")
    p.add_argument("--manifest",default="cases-manifest.json")
    p.add_argument("--run-root",help="Fresh output directory; existing run directories are never overwritten")
    args=p.parse_args()
    asyncio.run(main(args.only,args.manifest,args.run_root))
