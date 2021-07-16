include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/"


T = 100
T₀ = 1
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
    "peripherical" => (εshockfour, εshockone),
    "central" => (εshockone, εshockfour),
    "random" => (nothing, nothing),
    "permanent" => (εshockonepermanent, εshockonepermanent)
)

As, Gs = makestar(nodes)
Al, Gl = makepath(nodes)

results = Dict()

for (shockname, shockmatrices) in shocks
    
    println("Simulating $shockname...")

    εs, εg = shockmatrices

    Tₛ = shockname == "random" ? T * 2 : T

    dfagentstar, dfmodelstar, modelstar = plotfromsteadystate(
        As, Gs, Tₛ; εpath=εs, 
        plotpath=joinpath(plotpath, shockname, "star"),
        nodestoplot=[1, 3]
    )

    dfagentpath, dfmodelpath, modelpath = plotfromsteadystate(
        Al, Gl, Tₛ; εpath=εg, 
        plotpath=joinpath(plotpath, shockname, "path"),
        nodestoplot=[1, 2, 3]
    )

    results[shockname] = Dict(
        "star" => (dfagentstar, dfmodelstar, modelstar),
        "path" => (dfagentpath, dfmodelpath, modelpath)
    ) 
    
end

println("Done!")
