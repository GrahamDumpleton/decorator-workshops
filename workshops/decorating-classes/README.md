# Decorating classes

The last kind of target. Put a decorator on a class, watch it receive
the class object itself, and use that to synthesise a `__repr__`, add
ordering and equality, and freeze a class against assignment. Meet the
hashing trap that comes free with adding `__eq__` from outside the class
body, then find out that `@dataclass` is an ordinary decorator doing
what you have just done by hand.

Fifteen minutes, in a notebook. Python and its standard library only,
nothing to install.
