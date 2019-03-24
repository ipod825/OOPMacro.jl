using OOPMacro
using Test

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
