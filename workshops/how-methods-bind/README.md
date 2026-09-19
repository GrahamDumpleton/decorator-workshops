# How methods bind

Find out how `obj.method()` finds its instance, by doing the binding by
hand with `__get__`. Then pick up the class-based decorator that failed
on methods two workshops ago, give it a `__get__` of its own, and see
why that fixes the binding but not the shared state. Finish by writing a
descriptor that has nothing to do with decorators at all.

Twenty minutes, in a notebook. Python and its standard library only,
nothing to install.
