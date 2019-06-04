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
            @show bdo = BasicDotOpr(1)
            @time bdo.field0
            @time bdo.field0
            @time bdo.field0
            @test_throws(ErrorException, bdo.invalidfield)
            @test fun0(bdo, 1) == 2
            @time fun0(bdo, 1) == 2
            @time fun0(bdo, 1) == 2
            @time fun0(bdo, 1) == 2
            @test bdo.fun0(1) == 2
            @time bdo.fun0(1) == 2
            @time bdo.fun0(1) == 2
            @time bdo.fun0(1) == 2
        end
    end

    @testset "tests without dot operator" begin
        @testset "basic test" begin
            @show bndo = BasicNoDotOpr(1)
            @time bndo.field0
            @time bndo.field0
            @time bndo.field0
            @test_throws(ErrorException, bndo.invalidfield)
            @test fun0(bndo, 1) == 2
            @test_throws(ErrorException, bndo.fun0(1))
        end
    end
end
