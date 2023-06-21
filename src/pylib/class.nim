import std/macros

macro class*(obj, body: untyped): untyped = 
  # We accept "class Shape:" and "Class Shape(object):"
  let className = if obj.kind == nnkIdent: $obj else: $obj[0]
  
  result = newStmtList()
  
  for item in body:
    #[def has AST structure like this:
      Command
        Ident !"def"
        Call
          Ident !"argument"
          Ident !"second_argument"
          ExprEqExpr
            Ident !"default_arg"
            FloatLit 0.0
        StmtList
          procedure body here
    ]#
    # Other stuff than defines: comments, etc
    var def = item
    if def.kind != nnkCommand:
      continue
    var isAsync = false
    if $def[0] == "async" or $def[0] == "async_def" or $def[0] == "asyncdef":
      isAsync = true
    # a(b, c=1)
    let define = def[1]
    var procName = define[0]
    var isConstructor = false
    if $procName == "init":
      procName = newIdentNode("new" & className)
      isConstructor = true
    # Procedure return type (as string)
    var typ = if isConstructor: className else: "auto" 
    # First argument is the return type of the procedure
    var args = @[newIdentNode(typ)]
    # Statements which will occur before proc body
    var beforeBody = newStmtList()
    # Loop over all arguments expect procedure name
    for i in 1..<define.len:
      # Argument name
      let arg = def[1][i]
      # argument with default value
      if arg.kind == nnkExprEqExpr:
        args.add newIdentDefs(arg[0], newEmptyNode(), arg[1])
        continue
      # Special self argument
      if $arg == "self":
        # We need to create an instance of ref object
        # and we don't want to have instance as argument in a constructor
        if isConstructor:
          template construct(): untyped {.dirty.} = 
            var self: type(result)
            new(self)
          beforeBody.add getAst(construct())
          continue
        # We need to add it to procedure arguments
        # like self: Shape
        else:
          let arg = newIdentDefs(newIdentNode("self"), ident(className), newEmptyNode())
          args.add(arg)
          continue
      # Just add argument: auto
      args.add newIdentDefs(arg, ident("auto"), newEmptyNode())
    # Function body
    var firstBody = def[2]
    # Python special "doc" comment
    if firstBody[0].kind == nnkTripleStrLit:
      firstBody[0] = newCommentStmtNode($firstBody[0])
    # If we're generating a constructor proc - we need to return self
    # after we've created it
    if isConstructor:
      firstBody.add parseExpr("return self")
    # Add statement which will occur before function body
    beforeBody.add firstBody
    # Finally create a procedure and add it to result!
    if not isAsync: result.add newProc(procName, args, beforeBody, nnkProcDef)
    else: result.add newProc(procName, args, beforeBody, nnkProcDef, parseExpr("{.async.}"))
  # Echo generated code
  # echo result.toStrLit
