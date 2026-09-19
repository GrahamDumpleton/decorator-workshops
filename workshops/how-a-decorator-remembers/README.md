# How a decorator remembers

Find out how a wrapper still knows the function it wraps after the
decorator has returned. Open a closure and look inside the cell, build
functions that make functions, change a remembered value with
`nonlocal`, and reproduce and fix the late binding bug that catches
every Python developer once.

Fifteen minutes, in a notebook. Python and its standard library only,
nothing to install.
