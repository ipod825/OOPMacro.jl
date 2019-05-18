
# used for debugging
function printtrace()
    show(stdout, MIME"text/plain"(), stacktrace()[2:5])
    println()
end

"""
find the actual function call
    return example :(:call, :functionName, :arg1, :arg2, ...)
"""
function findFnCall(funExpr)
    funCall=funExpr
    if funExpr.head == :(=) || funExpr.head == :function
        funCall = funExpr.args[1]
    end
    if isa(funCall, Expr) && funCall.head == :where
        funCall = funCall.args[1]
    end
    if isa(funCall, Expr) && funCall.head == :call
        return funCall
    else
        dump(funCall)
        error("getFnCall: Could not detect function call")
    end
end

""" Find the symbol of the first argument to the function """
function findFnSelfArgNameSymbol(fun, ClsName=:Any)
    funCall = findFnCall(fun)
    self = funCall.args[2] # first arg
    if isa(self, Expr) && self.head == :parameters
        #FIXME: not sure how or why we get here, so log like crazy
        printtrace()
        dump(funCall)
        @show funCall.args[3]
        self = funCall.args[3]
    end

    if isa(self, Expr)
        # check if first arg is of correct type
        if ClsName!=:Any && self.args[2] != :($ClsName)
            error("$(self.args[1]) can only be declared of type '$ClsName', '$(self.args[2])' found!")
        end
        self = self.args[1]
    end
    return self
end

"""
Overwrite the first arg with
selfArgExpr eg. :(self::MyClass)
"""
function setFnSelf!(funExpr, selfArgExpr)
    funCall = findFnCall(funExpr)
    if isa(funCall.args[2], Expr) && funCall.args[2].head == :parameters
        funCall.args[3] = selfArgExpr
    else
        funCall.args[2] = selfArgExpr
    end
end

function deleteFnSelf!(fun)
    funCall = findFnCall(fun)
    self = funCall.args[2]
    if isa(self, Expr) && self.head == :parameters
        deleteat!(fun.args[1].args, 3)
    else
        deleteat!(fun.args[1].args, 2)
    end
end

function getFnParam(fun)
    printtrace()
    funCall = findFnCall(fun)
    # dump(funCall)
    # println(stacktrace())
    return funCall.args[2:end]
end

function setFnName!(fun, name; withoutGeneric=false)
    printtrace()
    if withoutGeneric
        funCall = findFnCall(fun)
        if isa(funCall.args[1], Symbol)
            funCall.args[1] = name
        else
            funCall.args[1].args[1] = name
        end
    else
        funCall = findFnCall(fun)
        funCall.args[1] = name
    end
end

function getFnName(fun; withoutGeneric=false)
    # dump(fun)
    # println(stacktrace())

    funCall = findFnCall(fun)
    name = funCall.args[1]

    if withoutGeneric
        if isa(name, Symbol)
            return name
        else
            return name.args[1]
        end
    else
        if isa(name, Symbol)
            return Expr(:curly, name)
        else
            return name
        end
    end
end

function setFnSelfArgType!(fun, ClsName)
    printtrace()
    @show fun
    selfArgNameSymbol = findFnSelfArgNameSymbol(fun)
    @show selfArgNameSymbol
    setFnSelf!(fun, :($selfArgNameSymbol::$ClsName))
    @show fun
end
