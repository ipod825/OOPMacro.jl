module OOP
export @class, @super

include("fnUtil.jl")


ClsMethods = Dict{Symbol, Dict{String, Expr}}()
ClsFields = Dict(:Any=>[])

macro class(ClsName, Cbody)
    if isa(ClsName, Expr)
        ParentClsName = ClsName.args[2]
        AbsParentClsName = Symbol(string("Abstract", ParentClsName))
        ClsName = ClsName.args[1]
    else
        ParentClsName = :Any
        AbsParentClsName = :Any
    end
    AbsClsName = Symbol(string("Abstract", ClsName))

    #= ParentCls = eval(ParentClsName) =#
    #= fields = [parse(string("$name::",fieldtype(ParentCls, name))) for name in fieldnames(ParentCls)] =#
    fields = copy(ClsFields[ParentClsName])

    method_str = String[]
    cons = Any[]
    hasInit = false

    # record fields and methods separately
    for (i, block) in enumerate(Cbody.args)
        if isa(block, Symbol) || block.head == :(::)
            append!(fields, [block])
        elseif block.head== :line
            continue
        elseif block.head == :(=) || block.head == :function
            fname = getFnName(block, withoutGeneric=true)
            if fname == ClsName
                append!(cons, [block])
            elseif fname == :__init__
                @assert !hasInit "Can't define multiple __init__"
                hasInit = true
                setFnName!(block, ClsName)
                self = getFnSelf(block, ClsName)
                deleteFnSelf!(block)
                prepend!(block.args[2].args, [:($self = $ClsName(()))])
                append!(block.args[2].args, [:($self)])
                append!(method_str, [string(block)])
            else
                self = getFnSelf(block, ClsName)
                setFnSelf!(block, :($self::$ClsName))
                append!(method_str, [string(block)])

                fname = getFnName(block)
                append!(fname.args, [:(OOPT<:$AbsClsName)])
                setFnSelf!(block, :($self::OOPT))
                setFnName!(block, fname)
                append!(method_str, [string(block)])
            end
        else
            error("@class: Case not handled")
        end
    end

    # Keep fields name in OOP module scope. Used when another class inherits ClsName
    ClsFields[ClsName] = fields

    if length(cons)>0
        cons_str = join(cons,"\n") * "\n"
    elseif hasInit
        cons_str = "$ClsName(::Tuple{}) = new()"
    else
        cons_str = ""
    end

    clsDefStr = ["abstract $AbsClsName <: $AbsParentClsName",
              """
              type $ClsName <: $AbsClsName
                  $(join(fields,"\n"))
              """ * cons_str * """
              end
              """]

    clsDefExpr = [parse(c) for c in clsDefStr]
    methodsExpr = [parse(m) for m in method_str]
    ClsMethods[ClsName] = Dict{String,Expr}()
    for (str, expr) in zip(method_str, methodsExpr)
        identifier = string(getFnCall(expr))
        identifier = replace(identifier, " ","")
        ClsMethods[ClsName][identifier] = expr
    end


    for c in clsDefExpr eval(c) end
    for m in methodsExpr eval(m) end


    # Escape here because we want ClsName and the methods be defined in user scope instead of OOP module scope.
    esc(Expr(:block, clsDefExpr..., methodsExpr...))
end

macro super(ParentClsName, Types, FCall)
    params = getFnParam(FCall)
    shouldInferenceType = isa(Types, Symbol)
    argTypes = :(Tuple{$ParentClsName})

    for i in 2:length(params)
        if shouldInferenceType || Types.args[i] == :_
            append!(argTypes.args, [Symbol(typeof(params[i]))])
        else
            append!(argTypes.args, [Types.args[i]])
        end
    end

    fname = getFnName(FCall, withoutGeneric=true)
    identifier = string(which(eval(fname), eval(argTypes)))
    identifier = split(identifier, ") at ")[1] * ")"
    identifier = replace(identifier, r"OOP.", "")
    identifier = replace(identifier, " ", "")
    method = copy(ClsMethods[ParentClsName][identifier])

    ClsName = isa(Types, Symbol)? Types: Types.args[1]
    superFname = Symbol(string("super",fname))
    self = getFnSelf(method)
    setFnName!(method, superFname, withoutGeneric=true)
    setFnSelf!(method, :($self::$ClsName))

    setFnName!(FCall, superFname)
    esc(Expr(:block, method, FCall))
end



end #module
