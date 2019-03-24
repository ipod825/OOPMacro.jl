using OOPMacro
using Test

@class SimpleCls begin
    field0
    field1::Int
    field2::Int

    #= Supports different style of function declaration =#
    fun0(self::SimpleCls, x) = self.field0 + x
    fun1(self, x, y) = begin
        self.field1 + x
    end
    function fun2(self, x)
        self.field2 + x
    end

    #= Generic function is also supported =#
    fun0{T<:Int}(self::SimpleCls, x::T) = self.field0 + x
    fun1{T<:Int}(self, x::T, y::T) = begin
        self.field1 + x
    end
    function fun2{T<:Int}(self, x::T)
        self.field2 + x
    end
end

s = SimpleCls(0,1,2)
@test s.field0 == 0
@test s.field1 == 1
@test s.field2 == 2
@test fun0(s, 2.) == 2
@test fun1(s, 2., 3) == 3
@test fun2(s, 2.) == 4
@test fun2(s, 2) == 4
fun2(s,"a")
@test_throws(MethodError, fun2(s,"a"))

@class SimpleCls1 begin
    field0::Int
    fun0(self, x, y=1) = self.field0 + x + y
    fun1(self, x, y=1; z=2) = self.field0 + x + y + z
end
s1 = SimpleCls1(0)
@test fun0(s1, 1) == 2
@test fun0(s1, 1, 2) == 3
@test fun1(s1, 1) == 4
@test fun1(s1, 1, 2) == 5
@test fun1(s1, 1, 2, z=3) == 6
