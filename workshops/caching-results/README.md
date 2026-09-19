# Caching results

Build the decorator you met in the first workshop. Write a naive cache
and watch recursive Fibonacci drop from twenty-two thousand calls to
twenty-one, break it twice on the cache key, fix it with
`inspect.signature` and `bind`, then use `functools.lru_cache` and find
out what unbounded caching costs, including the memory leak that comes
free with caching a method.

Fifteen minutes, in a notebook. Python and its standard library only,
nothing to install.
