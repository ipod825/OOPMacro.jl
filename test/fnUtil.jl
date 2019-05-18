using Test

funWithArgExpr = Meta.parse("fun1(self1::Class1, arg1::Int) = self1.field1")
funWithGenericArgExpr = Meta.parse("fun1(self1::Class1, arg1::T) where T<:Int = self1.field1")

function assertCall(fnCall)
    @test fnCall.head == :call
    @test fnCall.args[1] == :fun1
    @test fnCall.args[2].args[1] == :self1
    @test fnCall.args[3].args[1] == :arg1
end
assertCall(findFnCall(funWithArgExpr))
assertCall(findFnCall(funWithGenericArgExpr))

@test findFnSelfArgNameSymbol(funWithArgExpr) == :self1
@test findFnSelfArgNameSymbol(funWithGenericArgExpr) == :self1

function assertSetFnSelf(funExpr)
    fun = copy(funExpr)
    setFnSelf!(fun, :(self2::Class2))
    @test findFnSelfArgNameSymbol(fun) == :self2
    funCall = findFnCall(fun)
    @test funCall.args[2].args[1] == :self2
    @test funCall.args[2].args[2] == :Class2
end
assertSetFnSelf(funWithArgExpr)
assertSetFnSelf(funWithGenericArgExpr)

function assertSetFnSelfArgType(funExpr)
    fun = copy(funExpr)
    setFnSelfArgType!(fun, :(Class2))
    @test findFnSelfArgNameSymbol(fun) == :self1
    funCall = findFnCall(fun)
    @test funCall.args[2].args[1] == :self1
    @test funCall.args[2].args[2] == :Class2
end
assertSetFnSelfArgType(funWithArgExpr)
assertSetFnSelfArgType(funWithGenericArgExpr)

function assertDeleteFnSelf(funExpr)
    fun = copy(funExpr)
    deleteFnSelf!(fun)
    funCall = findFnCall(fun)
    @test funCall.args[2].args[1] == :arg1
end
assertDeleteFnSelf(funWithArgExpr)
assertDeleteFnSelf(funWithGenericArgExpr)
