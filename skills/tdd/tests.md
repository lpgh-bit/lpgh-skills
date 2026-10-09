# Good and Bad Tests

Examples are TypeScript for illustration; the principles hold in any language — use the project's own test framework.

## Good Tests

**Integration-style**: Test through real interfaces at the agreed seam, not mocks of internal parts.

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion (one concept) per test

### Arrange-Act-Assert

```typescript
it("marks overdue tasks when deadline has passed", () => {
  // Arrange
  const task = createTask({ title: "Test", deadline: new Date("2025-01-01") });
  // Act
  const result = checkOverdue(task, new Date("2025-01-02"));
  // Assert
  expect(result.isOverdue).toBe(true);
});
```

### DAMP over DRY

Each test is self-contained and readable without tracing shared helpers. Duplication is acceptable when it keeps each test independently understandable.

```typescript
it("rejects tasks with empty titles", () => {
  const input = { title: "", assignee: "user-1" };
  expect(() => createTask(input)).toThrow("Title is required");
});

it("trims whitespace from titles", () => {
  const input = { title: "  Buy groceries  ", assignee: "user-1" };
  expect(createTask(input).title).toBe("Buy groceries");
});
```

### One concept per test, descriptive names

```typescript
// GOOD: reads like a specification
describe("TaskService.completeTask", () => {
  it("sets status to completed and records timestamp", ...);
  it("throws NotFoundError for non-existent task", ...);
  it("is idempotent — completing an already-completed task is a no-op", ...);
});

// BAD: vague names, everything in one test
it("works", ...);
it("validates titles correctly", () => {
  expect(() => createTask({ title: "" })).toThrow();
  expect(createTask({ title: "  hello  " }).title).toBe("hello");
  expect(() => createTask({ title: "a".repeat(256) })).toThrow();
});
```

### Prove-It test for a bug

```typescript
// Bug: "Completing a task doesn't set completedAt"
it("sets completedAt when task is completed", async () => {
  const task = await taskService.createTask({ title: "Test" });
  const completed = await taskService.completeTask(task.id);
  expect(completed.status).toBe("completed");
  expect(completed.completedAt).toBeInstanceOf(Date); // fails → bug confirmed
});
```

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});

// BAD: interaction-based — asserts on the query, not the result
it("calls db.query with ORDER BY created_at DESC", async () => {
  await listTasks({ sortBy: "createdAt", sortOrder: "desc" });
  expect(db.query).toHaveBeenCalledWith(expect.stringContaining("ORDER BY created_at DESC"));
});

// GOOD: state-based — asserts on the outcome
it("returns tasks sorted by creation date, newest first", async () => {
  const tasks = await listTasks({ sortBy: "createdAt", sortOrder: "desc" });
  expect(tasks[0].createdAt.getTime()).toBeGreaterThan(tasks[1].createdAt.getTime());
});
```

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface

```typescript
// BAD: Bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

**Tautological tests**: Expected value restates the implementation, so the test passes by construction.

```typescript
// BAD: Expected value is recomputed the way the code computes it
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});

// GOOD: Expected value is an independent, known literal
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```
