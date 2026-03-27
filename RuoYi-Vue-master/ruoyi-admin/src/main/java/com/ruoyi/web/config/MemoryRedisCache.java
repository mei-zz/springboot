package com.ruoyi.web.config;

import com.ruoyi.common.core.redis.RedisCache;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 开发环境 Redis 不可用时，使用内存缓存替代若依默认的 RedisCache。
 */
@Component
@Primary
@SuppressWarnings({ "unchecked", "rawtypes" })
public class MemoryRedisCache extends RedisCache {
    private final Map<String, CacheEntry> store = new ConcurrentHashMap<>();

    @Override
    public <T> void setCacheObject(String key, T value) {
        store.put(key, new CacheEntry(value, null));
    }

    @Override
    public <T> void setCacheObject(String key, T value, Integer timeout, TimeUnit timeUnit) {
        long expireAt = timeout == null || timeUnit == null ? -1L
                : System.currentTimeMillis() + timeUnit.toMillis(timeout);
        store.put(key, new CacheEntry(value, expireAt));
    }

    @Override
    public boolean expire(String key, long timeout, TimeUnit unit) {
        CacheEntry entry = getLiveEntry(key);
        if (entry == null) {
            return false;
        }
        entry.expireAt = System.currentTimeMillis() + unit.toMillis(timeout);
        return true;
    }

    @Override
    public long getExpire(String key) {
        CacheEntry entry = getLiveEntry(key);
        if (entry == null || entry.expireAt == null || entry.expireAt < 0) {
            return 0L;
        }
        long ttl = entry.expireAt - System.currentTimeMillis();
        return Math.max(ttl, 0L);
    }

    @Override
    public Boolean hasKey(String key) {
        return getLiveEntry(key) != null;
    }

    @Override
    public <T> T getCacheObject(String key) {
        CacheEntry entry = getLiveEntry(key);
        return entry == null ? null : (T) entry.value;
    }

    @Override
    public boolean deleteObject(String key) {
        return store.remove(key) != null;
    }

    @Override
    public boolean deleteObject(Collection collection) {
        boolean removed = false;
        for (Object key : collection) {
            removed |= store.remove(String.valueOf(key)) != null;
        }
        return removed;
    }

    @Override
    public <T> long setCacheList(String key, List<T> dataList) {
        List<T> copy = dataList == null ? Collections.emptyList() : new ArrayList<>(dataList);
        store.put(key, new CacheEntry(copy, null));
        return copy.size();
    }

    @Override
    public <T> List<T> getCacheList(String key) {
        Object value = getCacheObject(key);
        return value instanceof List ? (List<T>) value : Collections.emptyList();
    }

    @Override
    public <T> void setCacheMap(String key, Map<String, T> dataMap) {
        store.put(key,
                new CacheEntry(dataMap == null ? Collections.emptyMap() : new ConcurrentHashMap<>(dataMap), null));
    }

    @Override
    public <T> Map<String, T> getCacheMap(String key) {
        Object value = getCacheObject(key);
        return value instanceof Map ? (Map<String, T>) value : Collections.emptyMap();
    }

    @Override
    public <T> void setCacheMapValue(String key, String hKey, T value) {
        Map<String, Object> map = (Map<String, Object>) store.computeIfAbsent(key,
                unused -> new CacheEntry(new ConcurrentHashMap<>(), null)).value;
        map.put(hKey, value);
    }

    @Override
    public <T> T getCacheMapValue(String key, String hKey) {
        Map<String, Object> map = (Map<String, Object>) getCacheObject(key);
        return map == null ? null : (T) map.get(hKey);
    }

    @Override
    public <T> List<T> getMultiCacheMapValue(String key, Collection<Object> hKeys) {
        Map<String, Object> map = (Map<String, Object>) getCacheObject(key);
        if (map == null || hKeys == null) {
            return Collections.emptyList();
        }
        List<T> list = new ArrayList<>();
        for (Object hKey : hKeys) {
            list.add((T) map.get(String.valueOf(hKey)));
        }
        return list;
    }

    @Override
    public boolean deleteCacheMapValue(String key, String hKey) {
        Map<String, Object> map = (Map<String, Object>) getCacheObject(key);
        return map != null && map.remove(hKey) != null;
    }

    @Override
    public Collection<String> keys(String pattern) {
        String prefix = pattern == null ? "" : pattern.replace("*", "");
        return store.keySet().stream().filter(key -> getLiveEntry(key) != null && key.startsWith(prefix))
                .collect(Collectors.toList());
    }

    private CacheEntry getLiveEntry(String key) {
        CacheEntry entry = store.get(key);
        if (entry == null) {
            return null;
        }
        if (entry.expireAt != null && entry.expireAt > 0 && entry.expireAt < System.currentTimeMillis()) {
            store.remove(key);
            return null;
        }
        return entry;
    }

    private static final class CacheEntry {
        private final Object value;
        private Long expireAt;

        private CacheEntry(Object value, Long expireAt) {
            this.value = value;
            this.expireAt = expireAt;
        }
    }
}
