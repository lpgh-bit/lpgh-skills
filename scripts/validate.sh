#!/usr/bin/env bash
# Validate the lpgh-skills pack: frontmatter, invocation flags, catalog sync,
# stale names from the source repos, and relative links. Exit 1 on any error.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 -I - "$@" <<'PY'
import json, os, re, sys, glob

errors = []
def err(msg): errors.append(msg)

# --- manifests -------------------------------------------------------------
for p in (".claude-plugin/plugin.json", ".claude-plugin/marketplace.json"):
    try:
        data = json.load(open(p))
    except Exception as e:
        err(f"{p}: invalid JSON ({e})"); continue
    if p.endswith("plugin.json"):
        for a in data.get("agents", []):
            if not os.path.isfile(a): err(f"{p}: agent {a} missing")

# --- skills ----------------------------------------------------------------
skills = {}
for path in sorted(glob.glob("skills/*/SKILL.md")):
    d = path.split("/")[1]
    text = open(path).read()
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m: err(f"{path}: no frontmatter"); continue
    fm = dict(re.findall(r"^([A-Za-z-]+):\s*(.*)$", m.group(1), re.M))
    if fm.get("name") != d: err(f"{path}: name '{fm.get('name')}' != folder '{d}'")
    desc = fm.get("description", "").strip().strip('"')
    if not desc: err(f"{path}: missing description")
    if len(desc) > 1024: err(f"{path}: description {len(desc)} chars > 1024")
    cmd = fm.get("disable-model-invocation") == "true"
    if cmd != (fm.get("hide") == "true"):
        err(f"{path}: disable-model-invocation and hide (omp) must be set together")
    skills[d] = "cmd" if cmd else "auto"

# --- catalog sync ----------------------------------------------------------
cat = open("references/skill-catalog.md").read()
cat_names = set(re.findall(r"^\| `([a-z0-9-]+)` \|", cat, re.M))
agents = {os.path.basename(a)[:-3] for a in glob.glob("agents/*.md")}
for s in skills:
    if s not in cat_names: err(f"skill-catalog.md: skill '{s}' not listed")
for n in cat_names:
    if n not in skills and n not in agents: err(f"skill-catalog.md: '{n}' is neither a skill nor an agent")
for n, inv in re.findall(r"^\| `([a-z0-9-]+)` \| (cmd|auto) \|", cat, re.M):
    if n in skills and skills[n] != inv:
        err(f"skill-catalog.md: '{n}' marked {inv} but SKILL.md is {skills[n]}")

# --- stale names from the source repos -------------------------------------
STALE = [
    r"\btest-driven-development\b", r"\bdiagnosing-bugs\b", r"\bdebugging-and-error-recovery\b",
    r"\bdomain-modeling\b", r"\bdocumentation-and-adrs\b", r"\bgrill-with-docs\b", r"\bgrill-me\b",
    r"/grilling\b", r"\binterview-me\b", r"\bidea-refine\b", r"\bbatch-grill-me\b",
    r"\bspec-driven-development\b", r"\bplanning-and-task-breakdown\b", r"\bincremental-implementation\b",
    r"\bcode-review-and-quality\b", r"`/?code-review`", r"\bshipping-and-launch\b",
    r"\bresolving-merge-conflicts\b", r"\bsetup-matt-pocock-skills\b", r"\bask-matt\b",
    r"\busing-agent-skills\b", r"\bready-for-agent\b", r"\bready-for-human\b", r"\.scratch/",
    r"tasks/todo\.md", r"tasks/plan\.md",
]
# Files that intentionally name the old vocabulary (attribution, migration, mapping).
ALLOW = {"NOTICE.md", "README.md", "references/tickets.md", "skills/init/SKILL.md"}
for path in glob.glob("**/*.md", recursive=True) + glob.glob("**/*.sh", recursive=True):
    if path in ALLOW or path.startswith(("licenses/", "node_modules/", "scripts/")): continue
    for i, line in enumerate(open(path, errors="replace"), 1):
        for pat in STALE:
            if re.search(pat, line):
                err(f"{path}:{i}: stale name /{pat}/: {line.strip()[:100]}")

# --- removed addy commands / packages -------------------------------------
OLDCMD = re.compile(r"(?:^|[\s`(\"'])/(build|spec|plan|test|code-simplify|constraints|webperf)\b(?![/\w.-])|\bagent-skills:")
for path in glob.glob("skills/**/*.md", recursive=True) + glob.glob("references/*.md") + glob.glob("agents/*.md") + glob.glob("hooks/*.md"):
    for i, line in enumerate(open(path, errors="replace"), 1):
        if OLDCMD.search(line):
            err(f"{path}:{i}: removed addy command/package: {line.strip()[:100]}")

# --- routing table covers every skill --------------------------------------
routing = open("skills/work/ROUTING.md").read() + open("references/skill-catalog.md").read()
for s_ in skills:
    if s_ not in ("work",) and f"`{s_}`" not in open("skills/work/ROUTING.md").read() and not re.search(rf"\b{re.escape(s_)}\b", open("skills/work/ROUTING.md").read()):
        err(f"skills/work/ROUTING.md: skill '{s_}' is never routed")

# --- ticket template uses real skills + UI pairing --------------------------
tk = open("references/tickets.md").read()
for line in re.findall(r"^Skills: (.+)$", tk, re.M):
    names = [x.strip() for x in line.split(",")]
    for n in names:
        if n not in skills: err(f"references/tickets.md: template Skills lists unknown '{n}'")
    if ("frontend-ui-engineering" in names) != ("frontend-design" in names):
        err("references/tickets.md: UI template must pair frontend-design with frontend-ui-engineering")

# --- agents frontmatter -----------------------------------------------------
for path in glob.glob("agents/*.md"):
    m = re.match(r"^---\n(.*?)\n---\n", open(path).read(), re.S)
    fm = dict(re.findall(r"^([A-Za-z-]+):\s*(.*)$", m.group(1), re.M)) if m else {}
    if fm.get("name") != os.path.basename(path)[:-3] or not fm.get("description"):
        err(f"{path}: agent frontmatter needs name (= file name) and description")

# --- <plugin>/... paths in the subagent brief -------------------------------
for t in re.findall(r"<plugin>/([A-Za-z0-9_./-]+\.md)", open("skills/work/TICKET-BRIEF.md").read()):
    if not os.path.exists(t): err(f"skills/work/TICKET-BRIEF.md: <plugin>/{t} does not exist")

# --- README lists every skill and the right count ----------------------------
readme = open("README.md").read()
for s_ in skills:
    if f"`{s_}`" not in readme: err(f"README.md: skill '{s_}' missing from the skills table")
m = re.search(r"into (\d+) skills", readme)
if m and int(m.group(1)) != len(skills): err(f"README.md says {m.group(1)} skills, found {len(skills)}")

# --- relative links --------------------------------------------------------
LINK = re.compile(r"\]\(((?:\.\./|\./)?[A-Za-z0-9_./-]+\.(?:md|sh|cjs|txt|json))(?:#[^)]*)?\)")
TICK = re.compile(r"`((?:\.\./)+[A-Za-z0-9_./-]+\.(?:md|sh))`")
for path in glob.glob("skills/**/*.md", recursive=True) + glob.glob("references/*.md") + glob.glob("agents/*.md"):
    base = os.path.dirname(path)
    text = open(path).read()
    for target in LINK.findall(text) + TICK.findall(text):
        if target.startswith(("http", "./src/")): continue  # ./src/... = example paths in templates
        if not os.path.exists(os.path.normpath(os.path.join(base, target))):
            err(f"{path}: broken link -> {target}")

# --- report ----------------------------------------------------------------
n_cmd = sum(1 for v in skills.values() if v == "cmd")
print(f"{len(skills)} skills ({n_cmd} cmd, {len(skills)-n_cmd} auto), {len(agents)} agents")
if errors:
    print(f"{len(errors)} problem(s):")
    for e in errors: print("  - " + e)
    sys.exit(1)
print("OK")
PY
python3 -I scripts/routing_evals.py .
