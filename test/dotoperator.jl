using Test

@class BasicDotOpr begin
    field0::Int
    fun0(self::SimpleCls, x) = self.field0 + x
end

@class nodotoperator BasicNoDotOpr begin
    field0::Int
    fun0(self::SimpleCls, x) = self.field0 + x
end

@testset "dot operator tests" begin

    @testset "invalid option validation" begin
        @test_throws(LoadError, @macroexpand @class invalidoption MyCls begin end)
    end

    @testset "tests with dot operator" begin
        @testset "basic test" begin
            bdo = BasicDotOpr(1)
            @test fun0(bdo, 1) == 2
            @test bdo.fun0(1) == 2
        end
    end

    @testset "tests without dot operator" begin
        @testset "basic test" begin
            bndo = BasicDotOpr(1)
            @test_throws(UndefVarError, fun0(nbdo, 1))
            @test bndo.fun0(1) == 2
        end
    end
end
