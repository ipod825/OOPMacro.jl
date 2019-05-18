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

#function setFnSelf!(fun, selfArgExpr)

#
# function setFnSelfArgType!(fun, ClsName)
