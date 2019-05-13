module LMMP

    using CPLEX
    using JuMP
    export LMMPSolver
    include("Types.jl")
    include("Functions.jl")

end
