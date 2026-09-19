# Decorating async functions

Put an ordinary decorator on an `async def` and watch it fail without
saying so: it times the construction of a coroutine, reports
microseconds for a function that sleeps, and hands the caller an object
instead of an answer. Then write a wrapper that awaits, one decorator
that serves both sync and async, and see what happens to an event loop
when a wrapper blocks it.

Fifteen minutes, in a notebook. Python and its standard library only,
nothing to install.
