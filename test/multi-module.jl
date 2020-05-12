module MultiUse
    using Test
    using OOPMacro

    @class MUParent begin
        pfield::Int
        pfun(self) = self.pfield
    end

    module SomeOtherModule
        using OOPMacro
        @class MUParent begin
            otherField::Int
        end
    end

    @class MUChild(MUParent) begin
        cfield::Int
        pfun(self) = self.cfield
    end

    p = MUParent(0)
    c = MUChild(0,1)
    @test c.pfield == 0
    @test c.cfield == 1
    pvalue = p.pfield
    cvalue = c.cfield
    @test pfun(p) == pvalue
    @test pfun(c) == cvalue
end
