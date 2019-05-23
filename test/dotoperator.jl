using Test

@testset "invalid option validation" begin
    @test_throws(LoadError, @macroexpand @class invalidoption MyCls begin end)
end


@class BasicDotOpr begin
    field0::Int
    fun0(self::SimpleCls, x) = self.field0 + x
end

@class nodotoperator BasicNoDotOpr begin
    field0::Int
    fun0(self::SimpleCls, x) = self.field0 + x
end

@testset "basic test with dot operator" begin
    bdo = BasicDotOpr(1)
    @test fun0(bdo, 1) == 2
    @test bdo.fun0(1) == 2
end

@testset "basic test without dot operator" begin
    bndo = BasicDotOpr(1)
    @test_throws(UndefVarError, fun0(nbdo, 1))
    @test bndo.fun0(1) == 2
end
