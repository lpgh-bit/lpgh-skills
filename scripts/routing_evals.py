"""Deterministic routing evals for lpgh-skills (no tokens, no network).

Scores each prompt in evals/routing.json against the descriptions of all
model-invoked skills with TF-IDF cosine similarity (the description is what a
harness shows the model when it decides which skill to load).

- positive case: `expect` must rank within `top_k` (default 3)
- negative case: `not` must not rank #1
- collisions: two auto-skill descriptions with cosine >= 0.75 fail, >= 0.5 warn

Usage: python3 -I scripts/routing_evals.py [repo-root]
Exit 1 on failures.
"""
import glob
import json
import math
import os
import re
import sys
from collections import Counter

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..")
STOP = set("""a an and any are as at be before by for from in into is it its my need needs of on or our so
that the them this to use want we when with you your help me i can should would how what which while
user users do does also only not no every all one more than""".split())
COLLISION_WARN, COLLISION_ERROR = 0.5, 0.75


def stem(t):
    for suf in ("ally", "ing", "ed", "es", "al"):
        if len(t) > len(suf) + 3 and t.endswith(suf):
            t = t[: -len(suf)]
            break
    if len(t) > 3 and t.endswith("s") and not t.endswith("ss"):
        t = t[:-1]
    if len(t) > 4 and t.endswith("e"):
        t = t[:-1]
    if len(t) > 4 and t[-1] == t[-2] and t[-1] not in "aeiou":
        t = t[:-1]
    return t


def tokens(text):
    return [stem(w) for w in re.findall(r"[a-z0-9]+", text.lower()) if w not in STOP and len(w) > 1]


def frontmatter(path):
    text = open(path, encoding="utf-8").read()
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    fm = dict(re.findall(r"^([A-Za-z-]+):\s*(.*)$", m.group(1), re.M)) if m else {}
    return fm


def load_skills():
    skills = {}
    for p in sorted(glob.glob(os.path.join(ROOT, "skills/*/SKILL.md"))):
        fm = frontmatter(p)
        if fm.get("disable-model-invocation") == "true":
            continue  # user-invoked: never auto-routed
        name = os.path.basename(os.path.dirname(p))
        skills[name] = (fm.get("name", name) + " " + fm.get("description", "")).replace("-", " ")
    return skills


def tfidf(docs):
    df = Counter()
    toks = {k: tokens(v) for k, v in docs.items()}
    for t in toks.values():
        df.update(set(t))
    n = len(docs)
    idf = {w: math.log((n + 1) / (c + 1)) + 1 for w, c in df.items()}
    vecs = {}
    for k, t in toks.items():
        tf = Counter(t)
        vecs[k] = {w: (c / len(t)) * idf[w] for w, c in tf.items()} if t else {}
    return vecs, idf


def vec(text, idf):
    t = tokens(text)
    tf = Counter(t)
    return {w: (c / len(t)) * idf.get(w, 0.0) for w, c in tf.items()} if t else {}


def cos(a, b):
    num = sum(v * b.get(k, 0.0) for k, v in a.items())
    da = math.sqrt(sum(v * v for v in a.values()))
    db = math.sqrt(sum(v * v for v in b.values()))
    return num / (da * db) if da and db else 0.0


def main():
    skills = load_skills()
    vecs, idf = tfidf(skills)
    cases = json.load(open(os.path.join(ROOT, "evals/routing.json"), encoding="utf-8"))
    errors, warns, rank1, total = [], [], 0, 0

    for c in cases:
        for key in ("expect", "not"):
            if key in c and c[key] not in skills:
                errors.append(f"case '{c['prompt'][:50]}': '{c[key]}' is not a model-invoked skill")
        if errors and errors[-1].startswith("case"):
            continue
        q = vec(c["prompt"], idf)
        ranked = sorted(skills, key=lambda s: cos(q, vecs[s]), reverse=True)
        if "expect" in c:
            total += 1
            k = c.get("top_k", 3)
            pos = ranked.index(c["expect"]) + 1
            rank1 += pos == 1
            if pos > k:
                errors.append(f"'{c['prompt'][:60]}': expected {c['expect']} in top {k}, got #{pos} (top: {', '.join(ranked[:3])})")
        if "not" in c and ranked[0] == c["not"]:
            errors.append(f"'{c['prompt'][:60]}': {c['not']} must not rank #1")

    names = list(skills)
    for i, a in enumerate(names):
        for b in names[i + 1:]:
            s = cos(vecs[a], vecs[b])
            if s >= COLLISION_ERROR:
                errors.append(f"description collision {a} ~ {b}: {s:.2f}")
            elif s >= COLLISION_WARN:
                warns.append(f"similar descriptions {a} ~ {b}: {s:.2f}")

    print(f"routing evals: {len(cases)} cases, {len(skills)} auto skills, rank-1 {rank1}/{total}")
    for w in warns:
        print("  warn: " + w)
    for e in errors:
        print("  FAIL: " + e)
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
