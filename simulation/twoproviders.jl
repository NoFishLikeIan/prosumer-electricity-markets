include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/"

A = [0 1; 1 0]

Nnodes = size(A, 1)
G = makeG(A) # 1x1 matrix

T = 2_000
Tₒ, Tε = 10, 5

lowε, highε = last(default_params[:ε])
εpath = lowε * ones(T + 1, Nnodes)

# εpath[Tₒ:(Tₒ + Tε), 2] .= highε  
    
dfagent, dfmodel, model = plotallsimulation(
        A, G, T; εpath=εpath, 
        fromsteady=true,
        plotpath=joinpath(plotpath, "two")
    )
