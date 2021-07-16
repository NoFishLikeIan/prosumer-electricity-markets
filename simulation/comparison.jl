include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/"


T = 200
T₀ = 75
Tε = T₀:(T₀ + 10)
nodes = 7
lowε, highε = last(default_params[:ε])
εshock = lowε * ones(T, nodes)

εshockone = copy(εshock)
εshockone[Tε, 1] .= highε

εshockfour = copy(εshock)
εshockfour[Tε, 3] .= highε

εshockonepermanent = copy(εshock)
εshockonepermanent[T₀:end, 3] .= highε

shocks = Dict(
    "constant" => (εshock, εshock),
    "central" => (εshockone, εshockfour),
    # "peripherical" => (εshockfour, εshockone),
    # "random" => (nothing, nothing),
    # "permanent" => (εshockonepermanent, εshockonepermanent)
)

As, Gs = makestar(nodes)
Al, Gl = makepath(nodes)

results = Dict()

for (shockname, shockmatrices) in shocks
    
    println("Simulating $shockname...")

    εs, εg = shockmatrices

    dfagentstar, dfmodelstar, modelstar = plotallsimulation(
        As, Gs, T; εpath=εs, 
        fromsteady=true,
        plotpath=joinpath(plotpath, shockname, "star"),
        nodestoplot=[1, 3]
    )

    dfagentpath, dfmodelpath, modelpath = plotallsimulation(
        Al, Gl, T; εpath=εg, 
        fromsteady=true,
        plotpath=joinpath(plotpath, shockname, "path"),
        nodestoplot=[1, 2, 3]
    )

    results[shockname] = Dict(
        "star" => (dfagentstar, dfmodelstar, modelstar),
        "path" => (dfagentpath, dfmodelpath, modelpath)
    ) 
    
end

println("Done!")
