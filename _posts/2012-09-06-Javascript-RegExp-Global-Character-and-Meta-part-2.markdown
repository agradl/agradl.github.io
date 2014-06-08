---
layout: post
title: Javascript RegExp Global, Character, and Meta (part 2)
categories: javascript
excerpt: enhance your regex using flags, classes, and meta

---

**Global Modifier**

Use the global modifier when you want to operate on all cases and not just the first.

{% prism javascript %}
"123example123".match(/2/g) // yields ["2", "2"]
"123example123".replace(/2/g,"-") // yields "1-3example1-3"
{% endprism %}

**Character classes**

Character classes are a way to match a single character. They can be defined using a set of criteria within the square brackets [ and ] or selected from some special pre-made classes which are declared using meta characters.

{% prism javascript %}
'123digit123'.replace(/\d/g,'-'); //yields "---digit---"
'123digit123'.replace(/[0-9]/g,'-'); //same
{% endprism %}

**Meta characters**

Not all characters are treated equally and many times their location determines their meaning. Within a character class, the carrot ^ in the first position reverses the meaning of the entire class.

{% prism javascript %}
'123nondigit123'.replace(/[^0-9]/g,'-'); // "123--------123"
'123nondigit123'.replace(/\D/g,'-'); // same
'123digit^and^carrot123'.replace(/[0-9^]/g,'-') // "---digit-and-carrot---"
{% endprism %}