---
layout: post
title: Tfs Build Template Test Category Filter
categories: .net tfs

---

Build automation is a great feature of Tfs 2010, but when you start adding a significant number of unit tests and especially integration tests, the build process begins to drag. Luckily there's built in support for this sort of issue.

The DefaultBuildTemplate.xaml has a field under the Test Assembly options called "Category Filter". The value of this field is used for the [/category](http://msdn.microsoft.com/en-us/library/ms182489.aspx#category) switch when the Build Controller runs MSTest.exe on your solution. 

So now when you write your MSTests and decorate the method with the appropriate attribute, you can filter out longer running tests depending on the the build.

{% prism csharp %}
[TestMethod]
[TestCategory("Integration")]
public void Create()
{
    _controller.Create();
}
{% endprism %}

And the Build Definition property value

{% prism csharp %}
Category Filter : !Integration
{% endprism %}