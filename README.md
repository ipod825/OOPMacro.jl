# OOP

A Julia package for writing Julia in Object Oriented Programming style.

-------

## Usage Example

### Basic
```julia
using OOP

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
end
s = SimpleCls(0,1,2)

#= Note that instead of s.fun0(1), we use fun0(s,1).
It's possible to make the former style works, but with great performance cost =#
fun0(s, 1)
```

### Constructor
You can use native julia constructor.
```julia
using OOP

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
Alternatively, use python style `__init__` provide by OOP:
```julia
using OOP
@class ConInit1 begin
    field1::Int
    field2::Int
    __init__(self, f1) = begin
        self.field1 = f1
        self.field2 = f1
    end
end

cInit1 = ConInit1(2)
```
Keyword arguments are supported too (this is also true for normal functions):
```julia
using OOP
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

cInit3a = ConInit3(2)
cInit3b = ConInit3(2,f2=3)
```

### Inheritance
Yes, we support concrete class inheritance! Though the underlying concept is tricky, the behavior looks just like you are writing python.
```julia
using OOP
using Base.Test

@class Parent begin
    pfield::Int
    pfun(self,x) = self.pfield + x + 10
    pfun(self, x, y) = self.pfield + x + y + 10
    pfun2{T<:Number}(self, x::T) = self.pfield + x + 20
end

@class Child(Parent) begin
    cfield::Int
    cfun(self::Child, x) = self.cfield - x -10
    cfun(self::Child, x, y) = self.cfield - x - y - 10
    cfun2{T<:Number}(self, x::T) = self.cfield - x - 20
end

#= Note that pfield is inherited by the Child =#
c = Child(0,1)
@test pfun(c,1)==11
@test pfun(c,1,2)==13
@test pfun2(c,1)==21
@test cfun(c,1)==-10
@test cfun(c,1,2)==-12
@test cfun2(c,1)==-20
```
As shown in the example, generic parameters is also supported.

### super
Calling parent's function is trickier than simple polymorphism. Due to some technical limitation (or maybe my poor knowledge). The syntax is a little verbose.

```julia
using OOP
using Base.Test

identityNotInOOP(x)=x

@class Parent begin
    pfield::Int
    pfun(self,x) = self.pfield + x + 10
    pfun(self, x, y) = self.pfield + x + y + 10
    pfun2{T<:Number}(self, x::T) = self.pfield + x + 20
end

@class Child(Parent) begin
    cfield::Int
    cfun3(self, x) = begin
        tmp = @super Parent Child pfun(self, x)
        tmp -= 10
        return tmp - x - 30
    end
    cfun3(self, x, y) = begin
        tmp = @super Parent Child pfun(self, x, y)
        tmp -= 10
        return tmp - x - y - 30
    end
    cfun4(self, x) = begin
        tmp = @super Parent (Child, Int64) pfun2(self, x)
        tmp -= 20
        return tmp - x - 40
    end
    cfun5(self, x, y) = begin
        tmp = @super Parent (Child, _, Int64) pfun(self, x, identityNotInOOP(y))
        tmp -= 10
        return tmp - x - y - 50
    end
end

@test cfun3(c,1) == -30
@test cfun3(c,1,2) == -30
@test cfun4(c,1) == -40
@test cfun5(c,1, 2) == -50
```
You should always provide Parent class, Child class name when using `@super`. In case that some argument is not passed as is (like `identityNotInOOP(y)` in `cfun5`), OOP can not determine which Parent function you want to call due to lack of type information of `identityNotInOOP(y)`. In such case, you must provide type information for that argument. `_` is a shortcut for you to skip arguments that are passed as is.

# Future Work
- Type generic parameter
- keyword arguments for super
- Multiple Inheritance support
