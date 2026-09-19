# Stacking decorators

Put more than one decorator on a function and find out that they are
applied in one order and run in the other. Predict the nesting before
you see it, watch a call travel in and out through both wrappers, meet a
stack where the order changes the answer rather than the output, and
walk the chain back to the original function through `__wrapped__`.

Fifteen minutes, in a notebook. Python and its standard library only,
nothing to install.
