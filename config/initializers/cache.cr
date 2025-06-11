require "cache"
require "redis_cache_store"

CACHE = Cache::RedisCacheStore(String, String).new(expires_in: 30.minutes)
