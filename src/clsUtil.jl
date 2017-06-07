function getCAndP(cls)
    if isa(cls, Symbol)
        C, P = cls, [:Any]
    elseif cls.head == :curly
        C, P = cls, [:Any]
    elseif cls.head == :call 
        C = cls.args[1]
        P = cls.args[2:end]
    else
        error("getCAndP: case not handled")
    end
    return C, P
end


function getAbstractCls(cls)
    abs = x::Symbol -> x==:Any? :Any : Symbol(string("Abstract", cls))
    if isa(cls, Array)
        return map(abs, cls)
    else
        return abs(cls)
    end
end


function copyFields(ParentClsNameLst, ClsFields)
    res = Set{Expr}()
    for parent in ParentClsNameLst
        conflict = intersect(res, ClsFields[parent])
        if length(conflict)!=0
            warn(join(conflict, ", ") * " in $patent overwritten")
        end
        res = union(res, ClsFields[parent])
    end
    return res
end
