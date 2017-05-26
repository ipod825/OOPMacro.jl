function getFnCall(fun)
    if fun.head == :(=) || fun.head == :function
        return fun.args[1]
    elseif fun.head == :call
        return fun
    else
        error("getFnCall: Case not handled")
    end
end

function getFnSelf(fun, ClsName=:Any)
    funCall = getFnCall(fun)
    self = funCall.args[2]
    if isa(self, Expr) && self.head == :parameters
        self = funCall.args[3]
    end

    if isa(self, Expr)
        if ClsName!=:Any && self.args[2] != :($ClsName)
            error("$(self.args[1]) can only be declared of type '$ClsName', '$(self.args[2])' found!")
        end
        self = self.args[1]
    end
    return self
end

function setFnSelf!(fun, self)
    funCall = getFnCall(fun)
    if isa(funCall.args[2], Expr) && funCall.args[2].head == :parameters
        funCall.args[3] = self
    else
        funCall.args[2] = self
    end
end

function deleteFnSelf!(fun)
    funCall = getFnCall(fun)
    self = funCall.args[2]
    if isa(self, Expr) && self.head == :parameters
        deleteat!(fun.args[1].args, 3)
    else
        deleteat!(fun.args[1].args, 2)
    end
end

function getFnParam(fun)
    funCall = getFnCall(fun)
    return funCall.args[2:end]
end

function setFnName!(fun, name; withoutGeneric=false)
    if withoutGeneric
        funCall = getFnCall(fun)
        if isa(funCall.args[1], Symbol)
            funCall.args[1] = name
        else
            funCall.args[1].args[1] = name
        end
    else
        funCall = getFnCall(fun)
        funCall.args[1] = name
    end
end

function getFnName(fun; withoutGeneric=false)
    funCall = getFnCall(fun)
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
