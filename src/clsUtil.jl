
function getCAndP(cls)
    if isa(cls, Symbol)
        return cls, :Any
    elseif cls.head == :curly
        return cls, :Any
    elseif cls.head == :call 
        if !isa(cls.args[1], Symbol)
            error("Generic type inheritence is not supported")
        else
            return cls.args[1], cls.args[2]
        end
    else
        error("getCAndP: case not handled")
    end
end

function getAbstractCls(cls)
    if cls == :Any
        return :Any
    else
        return Symbol(string("Abstract", cls))
    end
end
