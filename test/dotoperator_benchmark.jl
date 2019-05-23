using BenchmarkTools
using Statistics

if !isdefined(Main, :B1DotOpr)
    @class B1DotOpr begin
        field1::Int
        fun1(self::SimpleCls, x) = self.field0 + x
    end
end
if !isdefined(Main, :B1NoDotOpr)
    @class nodotoperator B1NoDotOpr begin
        field1::Int
        fun1(self::SimpleCls, x) = self.field0 + x
    end
end

bg = BenchmarkGroup()
bg["DotOpr"] = BenchmarkGroup()
bg["NoDotOpr"] = BenchmarkGroup()

bg["DotOpr"]["get_field1"] = @benchmarkable o.field1 setup=(o = B1DotOpr(rand(Int)))
bg["NoDotOpr"]["get_field1"] = @benchmarkable o.field1 setup=(o = B1NoDotOpr(rand(Int)))

tune!(bg)
results = run(bg, verbose = true, seconds = 1)

med = median(results)
println(med)
j = judge(med["DotOpr"]["get_field1"], med["NoDotOpr"]["get_field1"])
println(j)
