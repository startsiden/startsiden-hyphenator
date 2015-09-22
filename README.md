startsiden-hyphenator
=====================

Hyphenates strings, comes with handy TemplateToolkit plugin.

For usage examples, check out the tests. Such as https://github.com/startsiden/startsiden-hyphenator/blob/master/t/hyphen.t#L11 and https://github.com/startsiden/startsiden-hyphenator/blob/master/t/hyphen-sedenne.t#L14.

By default, the hyphenator inserts soft hyphens (http://www.fileformat.info/info/unicode/char/00AD/index.htm). This can be changed when including the plugin:

```
[% USE Hyphenator ","; "menneskerettighetsorganisasjonssekretærkursmateriellet" | hyphen %]
```
