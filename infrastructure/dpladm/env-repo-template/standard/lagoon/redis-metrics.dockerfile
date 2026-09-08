FROM uselagoon/redis-8:latest

# Key-value store dedicated to Prometheus metric counters, kept separate from
# the instance backing Drupal's cache.
#
# Kept in sync with cms/lagoon/redis-metrics.dockerfile in dpl-web, which is
# the same image used for local development.
#
# The settings below have to be baked into the image rather than set in
# docker-compose. Lagoon does not propagate compose-level `environment` to the
# deployed service pods, and its own environment variables are scoped to the
# whole environment - setting MAXMEMORYPOLICY there would change the eviction
# behaviour of the cache instance too, which genuinely wants allkeys-lru.

# Counters must never be evicted. Prometheus tolerates a counter resetting to
# zero (rate() and increase() account for it), but a *partial* eviction leaves
# some series intact while others restart, which reads as a real drop in
# traffic rather than as a reset.
ENV MAXMEMORYPOLICY=noeviction

# With noeviction, running out of memory turns writes into errors, so keep a
# wide margin. Actual usage is a few hundred kilobytes - the series count is
# bounded by the number of distinct metric/label combinations, not by traffic.
ENV MAXMEMORY=256mb
