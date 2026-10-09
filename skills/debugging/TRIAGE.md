# Triage reference

Decision trees for localising a failure and building the Phase 1 loop. Read when you need to figure out *which* code path to target, or when the bug won't reproduce. Commands are placeholders — use the ones in `docs/agents/project.md`.

## Localise the layer

```
Which layer is failing?
├── UI/Frontend      → console, DOM, network tab (browser-testing-with-devtools)
├── API/Backend      → server logs, request/response
├── Database         → queries, schema, data integrity
├── Build tooling    → config, dependencies, environment
├── External service → connectivity, API changes, rate limits
└── Test itself      → is the test correct? (false negative)
```

Regression between two known states? Bisect with the loop command:

```bash
git bisect start
git bisect bad                    # current commit is broken
git bisect good <known-good-sha>
git bisect run <focused loop command>
```

## By error type

Obvious, fully-localised failures (a type error naming the line, a missing import) may skip straight to the fix — but still re-run the suite and say why you skipped the loop.

### Test failure

```
Test fails after a code change:
├── Changed code the test covers?
│   └── Is the test or the code wrong?
│       ├── Test outdated (behaviour change was intended) → update the test
│       └── Code has a bug → fix the code
├── Changed unrelated code?
│   └── Likely side effect → shared state, imports, globals
└── Test was already flaky?
    └── Timing, order dependence, external dependencies
```

Run the failing test alone, verbose, and in isolation (single file, no parallelism) to rule out test pollution.

### Build failure

```
├── Type error       → read it; check types at the cited location
├── Import error     → module exists? exports match? paths correct?
├── Config error     → syntax/schema of build config
├── Dependency error → manifest + lockfile; reinstall with the project's tool
└── Environment      → runtime/toolchain version, OS
```

### Runtime error

```
├── null/undefined access → trace the data flow: where does the value come from?
├── Network / CORS        → URLs, headers, server CORS config
├── Render error / blank  → error boundary, console, component tree
└── Wrong behaviour, no error → probe the data at each boundary (Phase 4)
```

## When it won't reproduce

```
├── Timing-dependent?
│   ├── timestamps in logs around the suspected area
│   ├── artificial delays to widen race windows
│   └── run under load / concurrency
├── Environment-dependent?
│   ├── compare runtime/browser versions, OS, env vars
│   ├── compare data (empty vs populated DB)
│   └── try in CI where the environment is clean
├── State-dependent?
│   ├── leaked state between tests or requests
│   ├── globals, singletons, shared caches
│   └── scenario in isolation vs after other operations
└── Truly random?
    ├── defensive logging at the suspected location
    ├── alert on the specific error signature
    └── document observed conditions; revisit when it recurs
```

## Safe fallbacks (containment, not a fix)

Under real time pressure, contain damage while the root-cause fix lands — and record removing/revisiting the fallback as a follow-up (via `/to-tickets`, append mode).

```typescript
// Safe default + warning instead of crashing
function getConfig(key: string): string {
  const value = process.env[key];
  if (!value) {
    console.warn(`Missing config: ${key}, using default`);
    return DEFAULTS[key] ?? '';
  }
  return value;
}

// Graceful degradation instead of a broken feature
function renderChart(data: ChartData[]) {
  if (data.length === 0) return <EmptyState message="No data for this period" />;
  try {
    return <Chart data={data} />;
  } catch (error) {
    console.error('Chart render failed:', error);
    return <ErrorState message="Unable to display chart" />;
  }
}
```

A fallback that silently swallows errors is a new bug. Always log, never hide.

## Instrumentation: add, remove, keep

**Add** when you can't localise to a line, the issue is intermittent, or several components interact.

**Remove** once the bug is fixed and guarded, when the log only helps during development, and always when it contains sensitive data.

**Keep (permanent)**: error boundaries with reporting, API error logs with request context, performance metrics on key user flows — see `observability-and-instrumentation`.
