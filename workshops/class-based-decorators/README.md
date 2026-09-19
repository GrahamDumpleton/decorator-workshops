# Decorators that are classes

Write a decorator as a class rather than a function. Keep the count in
an instance attribute where a reader expects to find it, discover that
the decorated function now reports the decorator's own docstring as its
description, fix that with `functools.update_wrapper`, use the
constructor in place of the extra layer a configurable decorator needs,
and see the one thing this kind still cannot do.

Fifteen minutes, in a notebook. Python and its standard library only,
nothing to install.
