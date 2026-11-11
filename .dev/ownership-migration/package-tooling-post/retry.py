"""Recheck ordinary regression after the verification owner's path fixes."""
import fcntl
import json
import check

with open("/home/wayne/devel/jane/.protemu-build.lock", "a") as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    check.run("ordinary-runtest-after-owner-fixes",
              check.DUNE + ["runtest", "--force", "-j5"])

records = [json.loads(x) for x in (check.OUT / "commands.jsonl").read_text().splitlines()]
latest = {}
for record in records:
    name = record["name"].replace("-after-owner-fixes", "")
    latest[name] = record
check.write("result-summary.json", dict(commands=records,
    historical_failures=[x for x in records if x["exit"]],
    final_failures=[x for x in latest.values() if x["exit"]]))
