---
layout: post
title: Javascript RegExp Intro (part 1)
categories: javascript
excerpt: literal vs new RegExp usage and match replace

---

In its simplest form, regex can be used just like you would use a string in the String.replace method.

{% prism javascript %}
'somestring'.replace('s','-'); //yields -omestring
'somestring'.replace(/s/,'-'); //same
'somestring'.replace(new RegExp('s',''),'-'); //same
{% endprism %}

This works fine for alpha numeric characters, but some characters need to be escaped using \ because they have special meaning within a regular expression.

All of these examples can be run easily using your favorite browser's javascript console.

Before digging further into the regular expression itself, it's a good idea to understand how they can be used.

### RegExp object usage

+ exec - returns the first match of the passed string in a new array, even if the global modifier is specified

	{% prism javascript %}
new RegExp('h').exec('abcdefghij');   //["h"]
/h/.exec('abcdefghhj');               //["h"]
/h/g.exec('abcdefghhj');               //["h"]
{% endprism %}

+ test - returns true or false depending whether a match was found

	{% prism javascript %}
new RegExp('h').exec('abcdefghij')  //true
new RegExp('x').exec('abcdefghij')  //false
{% endprism %}

**String extension method usage**

+ replace - replaces the first match (or all if using the global modifier) with the provided replacement string

	{% prism javascript %}
'abcdefg'.replace(/c/,'-') //yields ab-cdefg
{% endprism %}

+ match - returns first match in an array (or all if using the global modifier)

	{% prism javascript %}
'abcdecg'.match(/c/) //yields ['c']
'abcdecg'.match(/c/g) //yields ['c','c']
{% endprism %}