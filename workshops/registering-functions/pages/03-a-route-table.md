---
title: A route table
requires: [verify:routes-work]
---

# A route table

Change the word from "command" to "path" and you have written the core
of a web framework.

```{cell-insert}
:id: insert-routes
:path: {{ notebook }}
:tags: [routes]
:run: true
routes = {}

def route(path):
    def decorator(func):
        routes[path] = func
        return func
    return decorator

@route("/")
def index():
    return "home page"

@route("/about")
def about():
    return "about us"

def handle(path):
    handler = routes.get(path)
    if handler is None:
        return "404 not found"
    return handler()

print(handle("/"))
print(handle("/about"))
print(handle("/missing"))
```

That is genuinely the shape Flask uses. A real one keeps more per entry,
the HTTP methods it accepts and a pattern rather than a fixed string,
and matches with something cleverer than a dictionary lookup. But
`@app.route("/")` above a function, putting it in a table that a
dispatcher consults later, is exactly this.

Knowing that changes how the framework reads. `@app.route` is not
special syntax and not framework magic; it is a decorator closing over a
path, storing your function, and giving it back. Which also explains
something people find surprising: a Flask view function is perfectly
callable by hand in a test, because it was never wrapped.

```{verify}
:id: routes-work
:label: The route table dispatches, and unknown paths fall through
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed routes
handle("/") == "home page" and handle("/about") == "about us" and handle("/missing") == "404 not found" and routes["/"] is index
```

```{hint}
:title: Why the decorator takes the path rather than reading it
Because the function's name is a poor URL and a worse API. Deriving
`/about` from `def about()` would work until you wanted `/about-us`, a
path with a slash in it, or two paths for one view. Taking the path
explicitly costs one argument and keeps the two independent.
```
