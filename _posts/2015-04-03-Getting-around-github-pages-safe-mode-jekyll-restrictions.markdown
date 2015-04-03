---
layout: post
title: Getting around github pages safe mode jekyll restrictions
categories: gh-pages
excerpt: Use all the features of jekyll you want and still host on github pages

---

One of the first surprises most people encounter when hosting their website on [github pages](https://pages.github.com/) is that [jekyll](http://jekyllrb.com/) doesn't work quite the as they expect. This is because they run a safe mode jekyll configuration with a [whitelist of plugins](https://help.github.com/articles/using-jekyll-plugins-with-github-pages/) for you to use. Since jekyll generates a static website, this is easy to work around by just generating your website locally and then pushing just the static site to github pages.

To get started you'll want to have the following:
+ some form of ruby, I prefer using [rvm](https://rvm.io/) to manage multiple ruby versions
+ [jekyll](http://jekyllrb.com/) locally installed

Then create your jekyll site in a new branch of your repository. This is where you will make future changes to the site.

To deploy your site to github pages, you can perform the following steps or just put them in a shell script for repeated use.

{% prism bash %}
jekyll build
cp ./_config.yml ./_site/_config.yml
cp ./CNAME ./_site/CNAME
cd _site
git init
git add --all
git commit -m "update"
git push -f https://github.com/agradl/agradl.github.io.git master
cd ../
rm -rf _site
{% endprism %}

Note: if this is for a project page, then instead of pushing to the **master** branch, you should be pushing to the **gh-pages** branch.