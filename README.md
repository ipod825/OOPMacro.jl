# OOPMacro

A Julia package for writing Julia in Object Oriented Programming style.

-------

## Usage Example

### Basic
Use `@class` to define a `class`. Defining functions is just as the same as in plain julia. Generic function/keyword arguments are all supported.
```julia
using OOPMacro

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

@class SimpleCls1 begin
    field0::Int
    fun0(self, x, y=1) = self.field0 + x + y
    fun1(self, x, y=1; z=2) = self.field0 + x + y + z
end

s = SimpleCls(0,1,2)
fun0(s, 1)

s1 = SimpleCls1(0)
fun1(s1, 1, 2, z=3)

```
Note that instead of `s.fun0(1)`, we use `fun0(s,1)`.
It's possible to make the former style works, but with great performance cost


### Constructor
You can use native julia constructor.
```julia
using OOPMacro

@class ConsNative begin
    field1::Int
    field2::Int
    ConsNative(f1) = begin
        self = new(f1)
        self.field2 = f1
        self
    end
end
cNative = ConsNative(2)
```
Alternatively, use python style `__init__` provide by OOPMacro:
```julia
using OOPMacro
@class ConInit3 begin
    field1::Int
    field2::Int
    __init__(self, f1=1; f2=1) = begin
        self.field1 = f1
        if f1>f2
            self.field2 = f1
        else
            self.field2 = f2
        end
    end
end

cInit3b = ConInit3(2,f2=3)
```

### Inheritance
Concrete class inheritance supported! Multiple class inheritance is also supported. Call super just like in python!!
```julia
using OOPMacro
using Base.Test

@class Parent begin
    pfield::Int
    pfun(self) = self.pfield
    pfunAdd(self,x) = self.pfield + x
end

@class Parent2 begin
    pfield2::Int
    pfun(self) = self.pfield2
    pfunAdd(self,x) = self.pfield2 + x
end

@class Child(Parent, Parent2) begin
    cfield::Int
    pfun(self) = self.cfield
    pfunAdd(self,x) = self.cfield + x
    cfunSuper(self) = @super Parent pfun(self)
    cfunAddSuper(self, x) = @super Parent pfunAdd(self, x)
    cfunSuper2(self) = @super Parent2 pfun(self)
    cfunAddSuper2(self, x) = @super Parent2 pfunAdd(self, x)
end

p = Parent(0)
c = Child(0,1,2)
pvalue = p.pfield
pvalue2 = c.pfield2
cvalue = c.cfield
@test pfun(p) == pvalue
@test pfun(c) == cvalue
@test pfunAdd(p,1) == pvalue + 1
@test pfunAdd(c,1) == cvalue + 1
@test_throws(MethodError, pfunAdd(c,"a"))

@test cfunSuper(c) == pvalue
@test cfunAddSuper(c,1) == pvalue+1

@test cfunSuper2(c) == pvalue2
@test cfunAddSuper2(c,1) == pvalue2+1
```


# Future Work
- Type generic parameter
