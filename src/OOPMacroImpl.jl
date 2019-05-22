include("fnUtil.jl")
include("clsUtil.jl")

#= ClsMethods = Dict{Symbol, Dict{Expr, Expr}}() =#
ClsMethods = Dict(:Any=>Dict{Expr, Expr}())
ClsFields = Dict(:Any=>Vector{Expr}())
validOptions = (:nodotoperator,)

macro class(args...)
    if length(args) < 2
        error("At least a class name and body must be specified.")
    end
    options = args[1:end-2]
    clsName = args[end-1]
    cBody = args[end]
    for o in options
        if o ∉ validOptions
            error("$o is not a valid option. Valid options are: $(join(validOptions, ", "))")
        end
    end
    supportDotOperator = :nodotoperator ∉ options

    clsName, ParentClsNameLst = getCAndP(clsName)
    AbsClsName = getAbstractCls(clsName)
    AbsParentClsName = getAbstractCls(ParentClsNameLst)

    ClsFields[clsName] = fields = copyFields(ParentClsNameLst, ClsFields)
    ClsMethods[clsName] = methods = Dict{Expr,Expr}()


    cons = Any[]
    hasInit = false

    # record fields and methods separately
    for (i, block) in enumerate(cBody.args)
        if isa(block, Symbol)
            union!(fields, [:($block::Any)])
        elseif isa(block, LineNumberNode)
            continue
        elseif block.head == :(::)
            union!(fields, [block])
        elseif block.head == :line
            continue
        elseif block.head == :(=) || block.head == :function
            fname = getFnName(block, withoutGeneric=true)
            if fname == clsName
                append!(cons, [block])
            elseif fname == :__init__
                hasInit = true
                setFnName!(block, clsName)
                self = findFnSelfArgNameSymbol(block, clsName)
                deleteFnSelf!(block)
                prepend!(block.args[2].args, [:($self = $clsName(()))])
                append!(block.args[2].args, [:($self)])
                append!(cons, [block])
            else
                fn = copy(block)
                setFnSelfArgType!(fn, clsName)
                methods[findFnCall(fn)] = fn
            end
        else
            error("@class: Case not handled")
        end
    end


    ClsFnCalls = Set(keys(methods))
    for parent in ParentClsNameLst
        for pfn in values(ClsMethods[parent])
            fn = copy(pfn)
            setFnSelfArgType!(fn, clsName)
            fnCall = findFnCall(fn)
            if haskey(methods, fnCall)
                fName = getFnName(fn, withoutGeneric=true)
                if !(fnCall in ClsFnCalls)
                    error("Ambiguious Function Definition: Multiple definition of function $fName while $clsName does not overwtie this function!!")
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
        cons_str *= "$clsName(::Tuple{}) = new()\n"
    end

    clsDefStr = """
              mutable struct $clsName
                  $(join(fields,"\n"))
              """ * cons_str * """
          end"""

    # this allows calling functions on the class..
    dotAccStr = """
              function Base.getproperty(self::$clsName, name::Symbol)
                  if name ∈ fieldnames($clsName)
                      getfield(self, name)
                  else
                      (args...; kwargs...)->eval(:(\$name(\$self, \$args...; \$kwargs...)))
                  end
              end
              """
    blockSections = [Meta.parse(clsDefStr), values(methods)...]
    if supportDotOperator
        push!(blockSections, Meta.parse(dotAccStr))
    end

    # Escape here because we want clsName and the methods be defined in user scope instead of OOPMacro module scope.
    esc(Expr(:block, blockSections...))
end

macro super(ParentClsName, FCall)
    fname = getFnName(FCall, withoutGeneric=true)
    setFnName!(FCall, Symbol(string("super_", ParentClsName, fname)), withoutGeneric=true)
    esc(FCall)
end
