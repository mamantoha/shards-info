require "cache"

CACHE = Cache::MemoryStore(String, String).new(expires_in: 30.minutes)
