[![Build Status](https://travis-ci.org/Yonaba/Moses.png)](https://travis-ci.org/Yonaba/Moses)
[![Coverage Status](https://coveralls.io/repos/Yonaba/Moses/badge.png?branch=master)](https://coveralls.io/r/Yonaba/Moses?branch=master)
[![License](http://img.shields.io/badge/Licence-MIT-brightgreen.svg)](LICENSE)
[![Join the chat at https://gitter.im/Yonaba/Moses](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Yonaba/Moses?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A Lua utility-belt library for [functional programming](http://en.wikipedia.org/wiki/Functional_programming). It complements the built-in __Lua table library__, making easier 
operations on arrays, lists, collections.<br/>

__Moses__ was deeply inspired by [Underscore.js](http://underscorejs.org).

## Download & Installation
### Bash

```bash
git clone git://github.com/Yonaba/Moses.git
````

### Archive
* __zip__: [1.6.0 (latest stable)](http://github.com/Yonaba/Moses/archive/Moses-1.6.0-1.zip) | [current](http://github.com/Yonaba/Moses/archive/master.zip) | [all](http://github.com/Yonaba/Moses/tags)
* __tarball__: [1.6.0 (latestt stable)](http://github.com/Yonaba/Moses/archive/Moses-1.6.0-1.tar.gz) | [current](http://github.com/Yonaba/Moses/archive/master.tar.gz) | [all](http://github.com/Yonaba/Moses/tags)

### LuaRocks
```
luarocks install moses
````

### MoonRocks

```bash
moonrocks install moses
````

or : 

```bash
luarocks install --server=http://rocks.moonscript.org/manifests/Yonaba moses
````

## Usage
Put the file [moses.lua](https://github.com/Yonaba/Moses/blob/master/moses.lua) inside your project folder and call it using *require* command.

*Note:* the full source [moses.lua](https://github.com/Yonaba/Moses/blob/master/moses.lua) is quite heavy (~68 kiB). You can alternatively use the [minified version](https://github.com/Yonaba/Moses/blob/master/moses_min.lua) (~22 kiB).

## Tutorial
Find a complete set of code examples in [tutorial.md](https://github.com/Yonaba/Moses/blob/master/doc/tutorial.md)
  
## Documentation
* Available in HTML-format for download : see [doc](https://github.com/Yonaba/Moses/blob/master/doc).
* Read it in your browser : see [online doc](http://yonaba.github.io/Moses/doc)

## Credits and Acknowledgement
* [Jeremy Ashkenas](https://github.com/jashkenas), for the amazing [Underscore.js](http://documentcloud.github.com/underscore/)
* [Marcus Irven](http://mirven.github.com/underscore.lua/)'s and [JTArchie](https://github.com/jtarchie/underscore-lua)'s 1-to-1 ports that also inspired this
* [Matthew Rocklin](https://github.com/mrocklin)'s [Toolz](https://github.com/pytoolz/toolz/) from which I borrowed some ideas
* [LDoc](https://github.com/stevedonovan/ldoc/) used to generate the current HTML documentation.

## Specification
Spec tests have been included.<br/>
Run them using [Telescope](https://github.com/norman/telescope) with the following command from the root folder:

```bash
tsc -f spec/*
```

## License
This work is under [MIT-LICENSE](http://www.opensource.org/licenses/mit-license.php)<br/>
Copyright (c) 2012-2017 Roland Yonaba. <br/>
See [LICENSE](LICENSE).

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/Yonaba/moses/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

