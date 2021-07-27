include("src/main.jl")
include("simulate.jl")

plotpath = "../plots"

T = 150 # Simulation time
τ = 100 # Shock init
Δτ = 10 # Shock length
Tₛ = 500 # Steady state periods
nodes = 7

lowε, highε = 2., 3.2
parameters = copy(default_params)

endowments = parameters[:ε]

parameters[:ε] = (first(endowments), (lowε, highε))

εconstant = constantshock(nodes, lowε)

shocks = Dict(
    # "constant" => (εconstant, εconstant),
    "central" => (
        makeshock(nodes, 1, τ, τ + Δτ, lowε, highε),
        makeshock(nodes, 4, τ, τ + Δτ, lowε, highε),
    ),
    # "peripherical" => (
    #     makeshock(nodes, 4, τ, τ + Δτ, lowε, highε), 
    #     makeshock(nodes, 1, τ, τ + Δτ, lowε, highε)
    # ),
    # "random" => (nothing, nothing),
    # "permanent" => (εshockonepermanent, εshockonepermanent)
)

As, Gs = makestar(nodes)
Al, Gl = makepath(nodes)

results = Dict()

for (shockname, shockmatrices) in shocks
    
    
    εs, εg = shockmatrices
    
    starnodestoplot = shockname == "peripherical" ? [1, 2, 3, 4] : [1, 4]  
    
    println("Simulating $shockname in star graph...")
    dfagentstar, dfmodelstar, modelstar = plotallsimulation(
        As, Gs, T; εpath=εs, 
        parameters=parameters,
        Tₛ=Tₛ,
        plotpath=joinpath(plotpath, shockname, "star"),
        nodestoplot=starnodestoplot
    )

    println("Simulating $shockname in path graph...")
    dfagentpath, dfmodelpath, modelpath = plotallsimulation(
        Al, Gl, T; εpath=εg, 
        parameters=parameters,
        Tₛ=Tₛ,
        plotpath=joinpath(plotpath, shockname, "path"),
        nodestoplot=[1, 2, 3, 4]
    )

    results[shockname] = Dict(
        "star" => (dfagentstar, dfmodelstar, modelstar),
        "path" => (dfagentpath, dfmodelpath, modelpath)
    ) 
    
end

println("Done!")