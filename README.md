# NimPylib

[![Build status](https://github.com/Yardanico/nimpylib/workflows/Build/badge.svg)](https://github.com/Yardanico/nimpylib/actions)
![](https://img.shields.io/github/languages/top/Yardanico/nimpylib?style=flat)
![](https://img.shields.io/github/stars/Yardanico/nimpylib?style=flat "Star NimPylib on GitHub!")
![](https://img.shields.io/maintenance/yes/2021?style=flat)
![](https://img.shields.io/github/languages/code-size/Yardanico/nimpylib?style=flat)
[![Issues](https://img.shields.io/github/issues-raw/Yardanico/nimpylib?style=flat)](https://github.com/Yardanico/nimpylib/issues)
[![PRs](https://img.shields.io/github/issues-pr-raw/Yardanico/nimpylib?style=flat)](https://github.com/Yardanico/nimpylib/pulls)
[![Commits](https://img.shields.io/github/last-commit/Yardanico/nimpylib?style=flat)](https://github.com/Yardanico/nimpylib/commits/)

Nimpylib is a collection of Python-like operators and functions (syntax sugar).
It can help you to translate your Python program to Nim.


# Usage

```nim
import pylib

print 42  # print can be used with and without parenthesis too, like Python2.
print( f"{9.0} Hello {42} World {1 + 2}" ) # Python-like string interpolation
let python_like_range = xrange(0, -10, -2) # range() is named xrange() like Python2
print(list(python_like_range)) # @[0, -2, -4, -6, -8]

# func definition
# typing is suppported and optional
def f(a: int, b = 1, *args) -> int:
  def add(a, b): return a + b # nesting
  for i in args: print(i)
  return add(a, b)

for i in xrange(10):
  # 0 1 2 3 4 5 6 7 8 9
  print(i, endl=" ")
print("done!")

# Python-like variable unpacking
let data = list(xrange(3, 15, 2))
data.unpack(first, second, *rest, last)
assert (first + second + last) == (3 + 5 + 13)
assert rest == @[7, 9, 11]

if (a := 6) > 5:
  assert a == 6

if (b := 42.0) > 5.0:
  assert b == 42.0

if (c := "hello") == "hello":
  assert c == "hello"

print(capwords("hello world capitalized")) # "Hello World Capitalized"
print("a".center(9)) # "         a         "

print("" or "b") # "b"
print("a" or "b") # "a"

print(not "") # true

print("Hello,", input("What is your name? "), endl="\n~\n")

pass # do nothing
pass str("This is a string.") # discard the string

let integer_bytes = 2_313_354_324
var bite, kilo, mega, giga, tera, peta, exa, zetta, yotta: int
(kilo, bite) = divmod(integer_bytes, 1_024)
(mega, kilo) = divmod(kilo, 1_024)
(giga, mega) = divmod(mega, 1_024)
(tera, giga) = divmod(giga, 1_024)
(peta, tera) = divmod(tera, 1_024)
(exa, peta)  = divmod(peta, 1_024)
(zetta, exa) = divmod(exa,  1_024)
(yotta, zetta) = divmod(zetta, 1_024)

let arg = "hello"
let anon = lambda: arg + " world"
assert anon() == "hello world"

print(json_loads("""{"key": "value"}""")) # {"key":"value"}

print(sys.platform) # "linux"

print(platform.processor) # "amd64"

var truty: bool
truty = all([True, True, False])
print(truty) # false

truty = any([True, True, False])
print(truty) # true

from std/os import sleep

timeit(100):  # Python-like timeit.timeit("code_to_benchmark", number=int)
  sleep(9)    # Repeats this code 100 times. Output is very informative.

# 2020-06-17T21:59:09+03:00 TimeIt: 100 Repetitions on 927 milliseconds, 704 microseconds, and 816 nanoseconds, CPU Time 0.0007382400000000003.

# Support for Python-like with statements
# All objects are closed at the end of the with statement
with open("some_file.txt", 'w') as file:
  file.write_line("hello world!")

with open("some_file.txt", 'r') as file:
  while not end_of_file(file):
    print(file.read_line())

with NamedTemporaryFile() as file:
  file.write_line("test!")

with TemporaryDirectory() as name:
  print(name)

type Example = ref object
  start: int
  stop: int
  step: int

class Example(object):  # Mimic simple Python "classes".
  """Example class with Python-ish Nim syntax!."""

  def init(self, start, stop, step=1):
    self.start = start
    self.stop = stop
    self.step = step

  def stopit(self, argument):
    """Example function with Python-ish Nim syntax."""
    self.stop = argument
    return self.stop

let e = newExample(5, 3)
print(e.stopit(5))
```

Nimpylib heavily relies on Nim generics, converters, operator overloading, and even on concepts.

- [Check the Examples folder for more examples.](https://github.com/Yardanico/nimpylib/tree/master/examples)
[Have more Macros or Templates for Python-like syntax, send Pull Request.](https://github.com/Yardanico/nimpylib/pulls)


# Installation

To install nimpylib, you can simply run
```
nimble install pylib
```

- Uninstall with `nimble uninstall pylib`. https://nimble.directory/pkg/pylib


# Requisites

- [Nim](https://nim-lang.org)


# Supported features

- [x] F-Strings `f"foo {variable} bar {1 + 2} baz"` and string functions
- [x] Python-like variable unpacking
- [x] Math with Float and Int mixed like Python.
- [x] `import antigravity`
- [x] `from __future__ import braces`
- [x] `lambda:`
- [x] `with open("file.ext", 'w'):` Read, write, append, and `file.read()`.
- [x] `with tempfile.TemporaryDirectory():` Read, write, append, and `file.read()`.
- [x] `with tempfile.NamedTemporaryFile() as file:` Read, write, append, and `file.read()`.
- [x] `timeit()` with Nanoseconds precision
- [x] `json.loads()` also can Pretty-Print
- [x] `True` / `False`
- [x] `pass` also can take and discard any arguments
- [x] `:=` Walrus Operator
- [x] `{"a": 1} | {"b": 2}` Dict merge operator
- [x] `|=` Dict merge operator
- [x] Python-like OOP class with methods and DocStrings (without inheritance)
- [x] `abs()`
- [x] `all()`
- [x] `any()`
- [x] `bin()`
- [x] `chr()`
- [x] `divmod()`
- [x] `enumerate()`
- [x] `filter()`
- [x] `float()`
- [x] `hex()`
- [x] `input()`
- [x] `int()`
- [x] `iter()`
- [x] `list()`
- [x] `map()`
- [x] `max()`
- [x] `min()`
- [x] `oct()`
- [x] `ord()`
- [x] `print("foo")` / `print "foo"` Python2 like
- [x] `range()` but named `xrange()` like in Python 2
- [x] `str()`
- [x] `sum()`
- [x] `<>` Python1 and Python2 `!=`
- [x] `long()` Python2 like
- [x] `unicode()` Python2 like
- [x] `ascii()` Python2 like
- [x] `u"string here"` / `u'a'` Python2 like
- [x] `b"string here"` / `b'a'` Python2 like
- [ ] `isinstance()`
- [ ] `issubclass()`
- [ ] `id()`
- More...


### Other Python-like modules

- https://nimble.directory/search?query=python
- [Full py2nim transpiler](https://github.com/metacraft-labs/py2nim)


### Tests

```console
$ nimble test
[OK] Range-like Nim procedure
[OK] Floor division
[OK] Class macro
[OK] tonim macro
[OK] String operations
[OK] Modulo operations
2020-06-17T22:07:28+03:00 TimeIt: 9 Repetitions on 118 microseconds and 711 nanoseconds, CPU Time 5.740999999999993e-05.
[OK] Miscelaneous
[OK] unpack macro
```


#### Stats

![Star nimpylib on GitHub](https://starchart.cc/Yardanico/nimpylib.svg "Star NimPylib on GitHub!")
