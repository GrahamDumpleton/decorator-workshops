# Decorators that take arguments

Make a decorator work on any function, then make it configurable.
Forward arguments with `*args` and `**kwargs` and see what breaks
without them, add the extra layer that `@repeat(3)` needs, build a
`@retry` that gives up loudly, and handle a decorator used both with and
without parentheses.

Fifteen minutes, in a notebook. Python and its standard library only,
nothing to install.
