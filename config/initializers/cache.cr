require "cache"
require "redis_cache_store"

CACHE              = Cache::RedisCacheStore(String, String).new(expires_in: 30.minutes)
ACTIVE_USERS_CACHE = Cache::RedisCacheStore(String, String).new(expires_in: 5.minutes, namespace: "active-users")
IPAPI_CACHE        = Cache::RedisCacheStore(String, String).new(expires_in: 30.days, namespace: "ipapi")
