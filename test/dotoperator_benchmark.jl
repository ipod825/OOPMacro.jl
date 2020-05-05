using Test
using BenchmarkTools
using Statistics

if !isdefined(Main, :B1DotOpr)
    @class B1DotOpr begin
        field1::Int
        fun1#::Function
        fun1(self::SimpleCls, x) = self.field1 + x
        B1DotOpr(field1::Int) = begin
            self =  __initOOPMacroFunctions(new(field1,nothing))
            #self.field1=field1
        end
    end
end
if !isdefined(Main, :B1NoDotOpr)
    @class nodotoperator B1NoDotOpr begin
        field1::Int
        fun1(self::SimpleCls, x) = self.field1 + x
        # B1NoDotOpr(field1::Int) = begin
        #     self = new()
        #     self.field1=field1
        # end
    end
end

bg = BenchmarkGroup()
bg["DotOpr"] = BenchmarkGroup()
bg["NoDotOpr"] = BenchmarkGroup()

bg["DotOpr"]["get_field1"] = @benchmarkable o.field1 setup=(o = B1DotOpr(rand(Int)))
bg["NoDotOpr"]["get_field1"] = @benchmarkable o.field1 setup=(o = B1NoDotOpr(rand(Int)))

bg["DotOpr"]["call_normal_fun1"] = @benchmarkable fun1(o, 1) setup=(o = B1DotOpr(rand(Int)))
bg["NoDotOpr"]["call_normal_fun1"] = @benchmarkable fun1(o, 1) setup=(o = B1NoDotOpr(rand(Int)))

bg["DotOpr"]["call_fun1"] = @benchmarkable o.fun1(1) setup=(o = B1DotOpr(rand(Int)))
bg["NoDotOpr"]["call_fun1"] = @benchmarkable fun1(o, 1) setup=(o = B1NoDotOpr(rand(Int)))

# bg["DotOpr"]["call_warm_fun1"] = @benchmarkable o.fun1(1) setup=(o = B1DotOpr(rand(Int)); o.fun1(1))
# bg["NoDotOpr"]["call_warm_fun1"] = @benchmarkable fun1(o, 1) setup=(o = B1NoDotOpr(rand(Int)); fun1(o, 1))

tune!(bg)
results = run(bg, verbose = true, seconds = 2)

@testset "tests if there are regressions" begin
    for t in ("get_field1", "call_normal_fun1",
        "call_fun1" #, "call_warm_fun1"
        )
        @testset "regressions in $t" begin
            med = median(results)
            #println(t, med)
            j = judge(med["DotOpr"][t], med["NoDotOpr"][t])
            println(t, ": ", j)
            @test !isregression(j)
        end
    end
end
