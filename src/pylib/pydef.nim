##[ python's def and async def

support:
  - param
  - param: type
  - param = defval
  - `*args`
  - -> restype
  - """doc-str""" or "doc-str"
  - nested def or async def
  
limits:
  - `*args` can only contain one type's arguments
  - can't combine type and defval i.e. `param: type = defval` is unsupported
  - for async def, only `-> Future[void]` can be omitted. Refer to std/asyncmacro for details
  - variables must be declared using `let`/`var`/`const` (this can be solved but is unnecessary)
  
unsupport:
  - generator (yield within def)  *TODO*
  - `**kws`
  - `*` and `/` in parameters-list
see codes in `when isMainModule` and `runnableExamples` for more details
]##
import std/macros
template emptyn: NimNode = newEmptyNode()
proc defImpl(signature, body: NimNode, pragmas = emptyn, def_restype = ident"auto"): NimNode
proc asyncImpl(defsign, body: NimNode): NimNode
proc defAux(signature, body: NimNode, def_argtype = ident"untyped", restype = def_argtype, nnkType = nnkTemplateDef, pragmas = emptyn): NimNode =
  ## XXX: deftype is for both params and result
  let name = signature[0]
  let slen = signature.len
  var params = @[restype]
  for i in 1 ..< slen:
    let param = signature[i]
    var
      pname: NimNode
      typ = def_argtype
      val = emptyn
    case param.kind
    of nnkIdent: # a
      pname = param
    of nnkExprEqExpr: # a = val
      pname = param[0]
      val = param[1]
    of nnkExprColonExpr: # a: typ
      pname = param[0]
      typ = param[1]
    of nnkPrefix: # *args or **kws(can't impl!)
      pname = param[1]
      case $param[0]
      of "*":
        typ = newNimNode(nnkBracketExpr).add(ident"varargs", def_argtype)
      of "**":
        error"can't implment **kws"
    else:
      error "unknown ast " & $param.kind

    params.add newIdentDefs(
            pname # name
           ,typ   # type
           ,val   # default value # can be omitted as empty node is default value
    )

  var nbody = newStmtList()
  if body[0].kind in nnkStrLit..nnkTripleStrLit:
    nbody.add newCommentStmtNode($body[0])
  else:
    nbody.add body[0]
  for ele in body[1..^1]: # for nested [async] def
    if ele.kind == nnkCommand:
      nbody.add case $ele[0]
        of "def": defImpl(ele[1], ele[2]) 
        of "async": asyncImpl(ele[1], ele[2])
        else: ele
    else:
      nbody.add ele
    
  newProc(name, params, nbody, nnkType, pragmas) 

template parseArrow{.dirty.} =
  mixin signature, name_params, restype
  if signature.kind == nnkInfix:
    expectIdent(signature[0], "->")
    name_params = signature[1]
    restype = signature[2]
macro define*(signature, body): untyped =
  ## almost the same as `def`, but is for `template` instead of `proc`
  ##
  ## XXX: nesting `define` is not allowed. If wanting, use `template`
  var
    name_params = signature
    restype = ident"untyped"
  parseArrow
  defAux(name_params, body)
proc defImpl(signature, body: NimNode, pragmas = emptyn, def_restype = ident"auto"): NimNode =
  var
    name_params = signature
    argtype = def_restype
    restype = argtype
  parseArrow
  defAux(name_params, body, argtype, restype, nnkProcDef, pragmas)


macro def*(signature, body): untyped =
  runnableExamples:
    def add(a,b): return a + b # use auto as argtype and restype
    def iadd(a: int, b = 1): return a + b
    def max(a, b, *args): # restype is omitted
      "doc-str. This is a fully python-compatiable `max`"
      def max2(a: int, b: int):
        if a>b: return a
        else: return b
      for i in args:
        result = max2(result, i)
      return result
    echo max(3,6,8,4) # this tells the code is Nim!"
  defImpl(signature, body)
proc asyncImpl(defsign, body: NimNode): NimNode =
  let 
    pre = defsign[0]
    signature = defsign[1]
  expectIdent(pre,"def")
  let
    apragma = newNimNode(nnkPragma).add(ident"async")
    restype = newNimNode(nnkBracketExpr).add(ident"Future", ident"void")
  defImpl(signature, body, apragma, restype)
macro async*(defsign, body): untyped = asyncImpl defsign, body
  ## `async def ...`
when isMainModule:
  define t(a, b):
    a & b
  echo t("a", "bc")
  def f(a: int, b = 1, *args) -> int:
    "a func"
    for i in args:
      echo i
    return a+b
  echo f(1,2, 'a', 'b')
  def nested():
    def f():
      return 1
    return f()
  echo nested()
  when not defined(nimscript):
    import std/asyncdispatch
    async def af():
      echo "no restype mean Future[void]"
    waitFor af()
    async def afi() -> Future[int]:
      return 3
    echo waitFor afi()
