include("src/main.jl")
include("simulate.jl")

A = [
    0 1;
    1 0
]

Nnodes = size(A, 1)
G = hcat(0) # 1x1 matrix

T = 100
Tₒ, Tε = 10, 5

lowε, highε = last(default_params[:ε])
εpath = lowε * ones(T + 1, Nnodes)

εpath[Tₒ:(Tₒ + Tε), 2] .= highε  
    
model = initializemodel(A, G, default_params; εpath=εpath)
dfagent, dfmodel = simulatemarket!(model; T=T)
