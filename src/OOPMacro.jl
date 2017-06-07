module OOPMacro
export @class, @super

include("fnUtil.jl")
include("clsUtil.jl")

#= ClsMethods = Dict{Symbol, Dict{Expr, Expr}}() =#
ClsMethods = Dict(:Any=>Dict{Expr, Expr}())
ClsFields = Dict(:Any=>Set{Expr}())


macro class(ClsName, Cbody)
    ClsName, ParentClsNameLst = getCAndP(ClsName)
    AbsClsName = getAbstractCls(ClsName)
    AbsParentClsName = getAbstractCls(ParentClsNameLst)

    ClsFields[ClsName] = fields = copyFields(ParentClsNameLst, ClsFields)
    ClsMethods[ClsName] = methods = Dict{Expr,Expr}()


    cons = Any[]
    hasInit = false

    # record fields and methods separately
    for (i, block) in enumerate(Cbody.args)
        if isa(block, Symbol)
            union!(fields, [:($block::Any)])
        elseif block.head == :(::)
            union!(fields, [block])
        elseif block.head== :line
            continue
        elseif block.head == :(=) || block.head == :function
            fname = getFnName(block, withoutGeneric=true)
            if fname == ClsName
                append!(cons, [block])
            elseif fname == :__init__
                hasInit = true
                setFnName!(block, ClsName)
                self = getFnSelf(block, ClsName)
                deleteFnSelf!(block)
                prepend!(block.args[2].args, [:($self = $ClsName(()))])
                append!(block.args[2].args, [:($self)])
                append!(cons, [block])
            else
                fn = copy(block)
                setFnSelfType!(fn, ClsName)
                methods[getFnCall(fn)] = fn 
            end
        else
            error("@class: Case not handled")
        end
    end


    ClsFnCalls = Set(keys(methods))
    for parent in ParentClsNameLst
        for pfn in values(ClsMethods[parent])
            fn = copy(pfn)
            setFnSelfType!(fn, ClsName)
            fnCall = getFnCall(fn)
            if haskey(methods, fnCall)
                fName = getFnName(fn, withoutGeneric=true)
                if !(fnCall in ClsFnCalls)
                    error("Ambiguious Function Definition: Multiple definition of function $fName while $ClsName does not overwtie this function!!")
                end
                setFnName!(fn, Symbol(string("super_", parent, fName)), withoutGeneric=true)
                methods[fnCall] = fn
            else
                methods[fnCall] = fn
            end
        end
    end

    cons_str = join(cons,"\n") * "\n"
    if hasInit
        cons_str *= "$ClsName(::Tuple{}) = new()\n"
    end

    clsDefStr = """
              type $ClsName
                  $(join(fields,"\n"))
              """ * cons_str * """
              end
              """

    # Escape here because we want ClsName and the methods be defined in user scope instead of OOPMacro module scope.
    esc(Expr(:block, parse(clsDefStr), values(methods)...))
end

macro super(ParentClsName, FCall)
    fname = getFnName(FCall, withoutGeneric=true)
    setFnName!(FCall, Symbol(string("super_", ParentClsName, fname)), withoutGeneric=true)
    esc(FCall)
end


end #module
