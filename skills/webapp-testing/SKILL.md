---
name: webapp-testing
description: Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs. In lpgh-skills the default tool for user-level browser tests (implement, milestone-review, hardening accessibility runs, design-phase screenshots).
license: Complete terms in LICENSE.txt
---

# Web Application Testing

## In lpgh-skills

Modified for lpgh-skills: this section and the description's last sentence were added; everything below "Original guidance" is unchanged from anthropics/skills.

- **Default tool for user-level browser tests** — the ticket's `User-level test` in `implement`, axis G of `milestone-review`, the accessibility check (axis 8) and acceptance test (axis 12) of the hardening suite ([`../../references/hardening.md`](../../references/hardening.md)), and design-phase screenshots. Headless, so it works in subagents and in omp. `browser-testing-with-devtools` (chrome-devtools MCP) is for interactive debugging when that MCP exists.
- **Never ask the user.** This runs inside subagents. Read how to start the app, its port/URL, seed data and test accounts from `docs/agents/project.md`; missing → discover them from the repo (package scripts, build files, README) and report the gap. If the app or Playwright can't run here, report the check as **not run** with the exact reason and what a human should run — never as passed.
- **Setup:** `python -c "import playwright"` fails → `pip install playwright && python -m playwright install chromium` (in a venv if the system Python is managed). `scripts/with_server.py` lives in this skill's folder — call it by its absolute path from the project root.
- **Screenshots** go to `.tickets/<effort>/design/` (design phase: `<screen>-<variant>.png`; reviews: `<screen>-<viewport>.png`) or the path the caller gives — never only `/tmp`. Take desktop (1280 wide) and mobile (390 wide) for UI checks.
- **Accessibility (axe) run:** inject axe-core into the page and fail on WCAG A/AA violations; then do the manual pass in [`../../references/accessibility-checklist.md`](../../references/accessibility-checklist.md#automated--manual-pass).
  - Python (default): load axe from a CDN, or from `node_modules/axe-core/axe.min.js` if the project has it:
    ```python
    page.add_script_tag(url="https://cdn.jsdelivr.net/npm/axe-core@4.10.2/axe.min.js")  # or path="node_modules/axe-core/axe.min.js"
    result = page.evaluate("""() => axe.run(document, {runOnly: {type: 'tag', values: ['wcag2a','wcag2aa','wcag21a','wcag21aa']}})""")
    for v in result["violations"]:
        print(v["impact"], v["id"], v["help"], [n["target"] for n in v["nodes"]])
    ```
  - JS project with Playwright tests already: `npm i -D @axe-core/playwright` and `new AxeBuilder({ page }).withTags(['wcag2a','wcag2aa']).analyze()` inside the existing test setup (a dev dependency is a reuse-first decision — record it in the ticket's `## Decisions`).
  - Run it on every new/changed screen and its key states (empty, error, open dialog).
- **Evidence** in your report: the steps you drove, observed results, console errors (see `examples/console_logging.py`), screenshot paths, axe violations by impact.

## Original guidance

To test local web applications, write native Python Playwright scripts.

**Helper Scripts Available**:
- `scripts/with_server.py` - Manages server lifecycle (supports multiple servers)

**Always run scripts with `--help` first** to see usage. DO NOT read the source until you try running the script first and find that a customized solution is abslutely necessary. These scripts can be very large and thus pollute your context window. They exist to be called directly as black-box scripts rather than ingested into your context window.

## Decision Tree: Choosing Your Approach

```
User task → Is it static HTML?
    ├─ Yes → Read HTML file directly to identify selectors
    │         ├─ Success → Write Playwright script using selectors
    │         └─ Fails/Incomplete → Treat as dynamic (below)
    │
    └─ No (dynamic webapp) → Is the server already running?
        ├─ No → Run: python scripts/with_server.py --help
        │        Then use the helper + write simplified Playwright script
        │
        └─ Yes → Reconnaissance-then-action:
            1. Navigate and wait for networkidle
            2. Take screenshot or inspect DOM
            3. Identify selectors from rendered state
            4. Execute actions with discovered selectors
```

## Example: Using with_server.py

To start a server, run `--help` first, then use the helper:

**Single server:**
```bash
python scripts/with_server.py --server "npm run dev" --port 5173 -- python your_automation.py
```

**Multiple servers (e.g., backend + frontend):**
```bash
python scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python your_automation.py
```

To create an automation script, include only Playwright logic (servers are managed automatically):
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True) # Always launch chromium in headless mode
    page = browser.new_page()
    page.goto('http://localhost:5173') # Server already running and ready
    page.wait_for_load_state('networkidle') # CRITICAL: Wait for JS to execute
    # ... your automation logic
    browser.close()
```

## Reconnaissance-Then-Action Pattern

1. **Inspect rendered DOM**:
   ```python
   page.screenshot(path='/tmp/inspect.png', full_page=True)
   content = page.content()
   page.locator('button').all()
   ```

2. **Identify selectors** from inspection results

3. **Execute actions** using discovered selectors

## Common Pitfall

❌ **Don't** inspect the DOM before waiting for `networkidle` on dynamic apps
✅ **Do** wait for `page.wait_for_load_state('networkidle')` before inspection

## Best Practices

- **Use bundled scripts as black boxes** - To accomplish a task, consider whether one of the scripts available in `scripts/` can help. These scripts handle common, complex workflows reliably without cluttering the context window. Use `--help` to see usage, then invoke directly. 
- Use `sync_playwright()` for synchronous scripts
- Always close the browser when done
- Use descriptive selectors: `text=`, `role=`, CSS selectors, or IDs
- Add appropriate waits: `page.wait_for_selector()` or `page.wait_for_timeout()`

## Reference Files

- **examples/** - Examples showing common patterns:
  - `element_discovery.py` - Discovering buttons, links, and inputs on a page
  - `static_html_automation.py` - Using file:// URLs for local HTML
  - `console_logging.py` - Capturing console logs during automation