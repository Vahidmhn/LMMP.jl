
mutable struct VerticeType
    Point :: Array{Float64,1}
    adj ::  Array{Int64,1}
    J :: Array{Int64,1}
    T :: Float64
end
