# Accessibility Checklist

Quick reference for WCAG 2.1 AA compliance. Use alongside the `frontend-ui-engineering` skill; `milestone-review` and the hardening suite (axis 8, [`hardening.md`](hardening.md)) run the [automated + manual pass](#automated--manual-pass).

## Table of Contents

- [Automated + manual pass](#automated--manual-pass)
- [Essential Checks](#essential-checks)
- [Common HTML Patterns](#common-html-patterns)
- [Testing Tools](#testing-tools)
- [Quick Reference: ARIA Live Regions](#quick-reference-aria-live-regions)
- [Common Anti-Patterns](#common-anti-patterns)

## Automated + manual pass

Run on every new or changed screen and its key states (empty, loading, error, open dialog), at desktop and mobile width. Works headless in a subagent — never ask the user; a step that can't run is reported as **not run** with the reason.

1. **Automated (axe):** with `webapp-testing`, inject axe-core and run it with tags `wcag2a, wcag2aa, wcag21a, wcag21aa` (snippet in `../skills/webapp-testing/SKILL.md`). Any violation on new UI is a finding; list it with rule id, impact and selector.
2. **Keyboard-only walk:** drive the flow with `page.keyboard.press("Tab")` / `Enter` / `Escape` only. Check every control is reachable in visual order, focus is visible (screenshot the focused state), no traps, dialogs trap and return focus, the skip link works.
3. **Contrast:** axe covers text; additionally check non-text UI (borders of inputs, focus rings, icons, chart colours) ≥ 3:1 against the `DESIGN.md` tokens, and that state isn't shown by colour alone.
4. **Reduced motion:** `browser.new_context(reduced_motion="reduce")` — animations stop or become non-moving fades, nothing is lost.
5. **Screen-reader labels:** `page.accessibility.snapshot()` (or `locator.aria_snapshot()`) — every control has a meaningful name and role, headings form an outline, live regions announce status/errors. A real screen-reader pass (Orca/NVDA/VoiceOver) is for the human checklist when the milestone is user-facing.
6. **Zoom/reflow:** 320 px width and 200 % text zoom without horizontal scroll or clipped content.

Record results per screen: pass / finding (with evidence) / not run (reason).

## Essential Checks

### Keyboard Navigation
- [ ] All interactive elements focusable via Tab key
- [ ] Focus order follows visual/logical order
- [ ] Focus is visible (outline/ring on focused elements)
- [ ] Custom widgets have keyboard support (Enter to activate, Escape to close)
- [ ] No keyboard traps (user can always Tab away from a component)
- [ ] Skip-to-content link at top of page - visible (at least) on keyboard focus
- [ ] Modals trap focus while open, return focus on close

### Screen Readers
- [ ] All images have `alt` text (or `alt=""` for decorative images)
- [ ] All form inputs have associated labels (`<label>` or `aria-label`)
- [ ] Buttons and links have descriptive text (not "Click here")
- [ ] Icon-only buttons have `aria-label`
- [ ] Page has one `<h1>` and headings don't skip levels
- [ ] Dynamic content changes announced (`aria-live` regions)
- [ ] Tables have `<th>` headers with scope

### Visual
- [ ] Text contrast ≥ 4.5:1 (normal text) or ≥ 3:1 (large text, 18px+)
- [ ] UI components contrast ≥ 3:1 against background
- [ ] Color is not the only way to convey information
- [ ] Text resizable to 200% without breaking layout
- [ ] No content that flashes more than 3 times per second

### Forms
- [ ] Every input has a visible label
- [ ] Required fields indicated (not by color alone)
- [ ] Error messages specific and associated with the field
- [ ] Error state visible by more than color (icon, text, border)
- [ ] Form submission errors summarized and focusable
- [ ] Known fields use autocomplete (for example `type="email" autocomplete="email"`)

### Content
- [ ] Language declared (`<html lang="en">`)
- [ ] Page has a descriptive `<title>`
- [ ] Links distinguish from surrounding text (not by color alone)
- [ ] Touch targets ≥ 44x44px on mobile
- [ ] Meaningful empty states (not blank screens)

## Common HTML Patterns

### Buttons vs. Links

```html
<!-- Use <button> for actions -->
<button onClick={handleDelete}>Delete Task</button>

<!-- Use <a> for navigation -->
<a href="/tasks/123">View Task</a>

<!-- NEVER use div/span as buttons -->
<div onClick={handleDelete}>Delete</div>  <!-- BAD -->
```

### Form Labels

```html
<!-- Explicit label association -->
<label htmlFor="email">Email address</label>
<input id="email" type="email" required />

<!-- Implicit wrapping -->
<label>
  Email address
  <input type="email" required />
</label>

<!-- Hidden label (visible label preferred) -->
<input type="search" aria-label="Search tasks" />
```

### ARIA Roles

```html
<!-- Navigation -->
<nav aria-label="Main navigation">...</nav>
<nav aria-label="Footer links">...</nav>

<!-- Status messages -->
<div role="status" aria-live="polite">Task saved</div>

<!-- Alert messages -->
<div role="alert">Error: Title is required</div>

<!-- Modal dialogs -->
<dialog aria-modal="true" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm Delete</h2>
  ...
</dialog>

<!-- Loading states -->
<div aria-busy="true" aria-label="Loading tasks">
  <Spinner />
</div>
```

### Accessible Lists

```html
<ul role="list" aria-label="Tasks">
  <li>
    <input type="checkbox" id="task-1" aria-label="Complete: Buy groceries" />
    <label htmlFor="task-1">Buy groceries</label>
  </li>
</ul>
```

## Testing Tools

```bash
# Automated audit
npx axe-core          # Programmatic accessibility testing
npx pa11y             # CLI accessibility checker

# In browser
# Chrome DevTools → Lighthouse → Accessibility
# Chrome DevTools → Elements → Accessibility tree

# Screen reader testing
# macOS: VoiceOver (Cmd + F5)
# Windows: NVDA (free) or JAWS
# Linux: Orca
```

## Quick Reference: ARIA Live Regions

| Value | Behavior | Use For |
|-------|----------|---------|
| `aria-live="polite"` | Announced at next pause | Status updates, saved confirmations |
| `aria-live="assertive"` | Announced immediately | Errors, time-sensitive alerts |
| `role="status"` | Same as `polite` | Status messages |
| `role="alert"` | Same as `assertive` | Error messages |

## Common Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| `div` as button | Not focusable, no keyboard support | Use `<button>` |
| Missing `alt` text | Images invisible to screen readers | Add descriptive `alt` |
| Color-only states | Invisible to color-blind users | Add icons, text, or patterns |
| Autoplaying media | Disorienting, can't be stopped | Add controls, don't autoplay |
| Custom dropdown with no ARIA | Unusable by keyboard/screen reader | Use native `<select>` or proper ARIA listbox |
| Removing focus outlines | Users can't see where they are | Style outlines, don't remove them |
| Empty links/buttons | "Link" announced with no description | Add text or `aria-label` |
| `tabindex > 0` | Breaks natural tab order | Use `tabindex="0"` or `-1` only |
