import std/macros

macro def*(obj, body: untyped): untyped = 
  let funcName = $obj[0]
  result = newStmtList()
  if true:
    # Other stuff than defines: comments, etc
    #if def.kind != nnkCommand:
    #  continue
    # a(b, c=1)
    var def = body
    let define = obj
    var procName = obj[0]
    var isConstructor = false
    # Procedure return type (as string)
    var typ = "auto" 
    # First argument is the return type of the procedure
    var args = @[newIdentNode(typ)]
    # Statements which will occur before proc body
    var beforeBody = newStmtList()
    # Loop over all arguments expect procedure name
    for i in 1..<define.len:
      # Argument name
      let arg = obj[i]
      # argument with default value
      if arg.kind == nnkExprEqExpr:
        args.add newIdentDefs(arg[0], newEmptyNode(), arg[1])
        continue
      # Special self argument
      # Just add argument: auto
      args.add newIdentDefs(arg, ident("auto"), newEmptyNode())
    # Function body
    var firstBody = body
    # Python special "doc" comment
    if firstBody[0].kind == nnkTripleStrLit:
      firstBody[0] = newCommentStmtNode($firstBody[0])
    # If we're generating a constructor proc - we need to return self
    # after we've created it
    if isConstructor:
      firstBody.add parseExpr("return self")
    # Add statement which will occur before function body
    beforeBody = firstBody #.add firstBody
    # Finally create a procedure and add it to result!
    result.add newProc(procName, args, beforeBody, nnkProcDef)
