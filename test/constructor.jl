using OOPMacro
using Test

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
@test cNative.field1 == cNative.field2


@class ConInit1 begin
    field1::Int
    field2::Int
    __init__(self, f1) = begin
        self.field1 = f1
        self.field2 = f1
    end

end

cInit1 = ConInit1(2)
@test cInit1.field1 == cInit1.field2

@class ConInit2 begin
    field1::Int
    field2::Int
    __init__(self, f1, f2=1) = begin
        self.field1 = f1
        if f1>f2
            self.field2 = f1
        else
            self.field2 = f2
        end
    end
end

cInit2a = ConInit2(2)
@test cInit2a.field1 == 2
@test cInit2a.field2 == 2

cInit2b = ConInit2(2,3)
@test cInit2b.field1 == 2
@test cInit2b.field2 == 3


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
@test cInit3a.field1 == 2
@test cInit3a.field2 == 2

cInit3b = ConInit3(2,f2=3)
@test cInit3b.field1 == 2
@test cInit3b.field2 == 3
