abstract AbstractConInit3 <: Any
type ConInit3 <: AbstractConInit3 # none, line 2:
    field1::Int # none, line 3:
    field2::Int # none, line 4:
    ConInit3(::Tuple{}) = begin  # none, line 4:
        new()
    end
end
ConInit3(f1=1; f2=2) = begin  # none, line 1:
    begin  # none, line 2:
        self = ConInit3(()) # none, line 3:
        begin  # none, line 4:
            self.field1 = f1 # none, line 5:
            if f1 > f2 # none, line 6:
                self.field2 = f1
            else  # none, line 8:
                self.field2 = f2
            end
        end # none, line 11:
        self
    end
end

c = ConInit3(1,f2=2)

