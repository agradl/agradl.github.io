---
layout: post
title: Simple object caching in .net
categories: .net
excerpt: Caching pocos in .net

---


Asp.Net makes it very easy to cache pages, actions and resources. However, sometimes I just want to cache some different objects and I don't want to have to adjust my code much to get the benefit. I created an ObjectCache class with that in mind.

{% prism csharp %}
public static class ObjectCache
	{
		private static readonly ConcurrentDictionary<object, CachedObject> 
			_cache = new ConcurrentDictionary<object, CachedObject>();

		public static T WrapAndRetrieve<T>(object key, Func<T> getNewValue, 
											int cacheDurationMinutes = 30)
		{
			return _cache
				.AddOrUpdate(key
				//function returning the CacheObject to add (cache miss)
					, o => new CachedObject(getNewValue(), cacheDurationMinutes)
				//function returning a new CacheObject if its expired
					, (o, c) => c.IsExpired ? 
						new CachedObject(getNewValue(),	cacheDurationMinutes) : 
						c)
				.GetValue<T>();
		}

		public static void Expire(object key)
		{
			CachedObject obj;
			_cache.TryRemove(key, out obj);
		}
		
		public static long EstimatedSize()
		{
			long l = 0;
			foreach (var obj in _cache)
			{
				l += get_size(obj.Value.GetValue<object>());
			}
			return l;
		}

		private static long get_size(object o)
		{
			long size = 0;
			using (Stream s = new MemoryStream())
			{
				BinaryFormatter formatter = new BinaryFormatter();
				formatter.Serialize(s, o);
				return s.Length;
			}
		}

		private class CachedObject
		{
			private DateTime expiration { get; set; }
			private readonly object _value;

			public CachedObject(object value, int duration)
			{
				_value = value;
				expiration = DateTime.Now.AddMinutes(duration);
			}

			public bool IsExpired
			{
				get { return expiration < DateTime.Now; }
			}

			public T GetValue<T>()
			{
				return (T)_value;
			}
		}
	}
{% endprism %}

Since I'm storing this in a static variable, its a good idea to get an estimated memory footprint. I've included a simple object memory estimate function to give a rough idea of the memory this cache takes up. The catch is to test it out you need to mark all of the objects you plan on storing into the cache as serializable.
	
![determine memory footprint](/img/Simple-object-caching-in-net/footprint.jpg "Estimated Size")