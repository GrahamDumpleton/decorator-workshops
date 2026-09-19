# Retrying and handling errors

Decorate the error path. Log a failure through the `logging` module
without swallowing it, translate an exception into your own while
keeping its cause attached, retry only the failures that are worth
retrying, and watch the stacking order decide whether your log records
failed operations or failed attempts.

Fifteen minutes, in a notebook. Python and its standard library only,
nothing to install.
