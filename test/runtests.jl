using OOPMacro
import OOPMacro: findFnCall, findFnSelfArgNameSymbol, setFnSelf!, deleteFnSelf!, setFnName!, getFnName, setFnSelfArgType!

testFiles = ("fnUtil.jl",
"basic.jl",
"constructor.jl",
"inheritence.jl",
"multi-module.jl")

@testset "Testing: $filename" for filename in testFiles
    include(filename)
end
