require "cache"
require "redis_cache_store"

CACHE              = Cache::RedisCacheStore(String).new(expires_in: 30.minutes)
IPAPI_CACHE        = Cache::RedisCacheStore(String).new(expires_in: 30.days, namespace: "ipapi")
