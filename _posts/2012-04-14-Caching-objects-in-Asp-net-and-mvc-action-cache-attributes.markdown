---
layout: post
title: Caching objects in Asp.net and mvc action cache attributes
categories: asp.net mvc
excerpt: Exploring some .net caching features

---

Previously, I designed my repository object so that hits to the file system would be eliminated after the post listings were stored in the asp.net cache. 

This seemed to work well enough, but if the underlying file were to change, the cache would become outdated. Luckily the cache object comes with some built in expiration dependency features.

{% prism csharp %}
void InsertIntoCache()
{
	var posts = _loader.GetPostDirectory();
	HttpContext.Current.Cache.Insert("Posts", posts, 
		new CacheDependency(posts.FilePath));
}
{% endprism %}

This causes the cache to expire should the referenced file ever change, so I can freely update the underlying file without worry about clearing the cache.

I could use a similar method for caching the files containing the Markdown, but since each object corresponds to a specific action call it's far easier just to utilize an MVC cache attribute.

{% prism csharp %}
[OutputCache(Duration=10, Location=OutputCacheLocation.Server)]
public virtual ActionResult Post(int id, string slug = "")
{
	return View(_repo.GetSinglePost(id));
}
{% endprism %}