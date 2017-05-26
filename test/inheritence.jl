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
    cfun(self::Child, x) = self.cfield - x -10
    cfun(self::Child, x, y) = self.cfield - x - y - 10
    cfun2{T<:Number}(self, x::T) = self.cfield - x - 20
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


c = Child(0,1)
@test c.pfield==0
@test c.cfield==1
@test pfun(c,1)==11
@test pfun(c,1,2)==13
@test pfun2(c,1)==21
@test cfun(c,1)==-10
@test cfun(c,1,2)==-12
@test cfun2(c,1)==-20
@test_throws(MethodError, cfun2(c,"a"))
@test cfun3(c,1) == -30
@test cfun3(c,1,2) == -30
@test cfun4(c,1) == -40
@test cfun5(c,1, 2) == -50
