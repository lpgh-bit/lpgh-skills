# When to Mock

Use the simplest test double that does the job. The more real code a test runs, the more confidence it gives.

```
Preference order (most → least preferred):
1. Real implementation  → highest confidence, catches real bugs
2. Fake                 → working in-memory version of a dependency (e.g. fake DB)
3. Stub                 → returns canned data, no behaviour
4. Mock (interaction)   → verifies calls — use sparingly
```

Mock at **system boundaries** only — where the real thing is slow, non-deterministic, or has side effects you can't control:

- External APIs (payment, email, etc.)
- Databases (sometimes — prefer a test DB or a fake)
- Time/randomness
- File system (sometimes)

Don't mock:

- Your own classes/modules
- Internal collaborators
- Anything you control

Over-mocking produces tests that pass while production breaks.

## Designing for Mockability

At system boundaries, design interfaces that are easy to substitute. (Examples are TypeScript for illustration; the idea is language-agnostic.)

**1. Use dependency injection**

Pass external dependencies in rather than creating them internally:

```typescript
// Easy to substitute
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to substitute
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. Prefer SDK-style interfaces over generic fetchers**

Create specific functions for each external operation instead of one generic function with conditional logic:

```typescript
// GOOD: Each function is independently substitutable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: Mocking requires conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

The SDK approach means:
- Each double returns one specific shape
- No conditional logic in test setup
- Easier to see which endpoints a test exercises
- Type safety per endpoint

A boundary interface with one production adapter and one test adapter is a real seam — see `/codebase-design`.
