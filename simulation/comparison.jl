include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/"

Plots.resetfontsizes(); Plots.scalefontsizes(0.8)
default(size=(1000, 800), margin=5Plots.mm) # Plotting defaults

T = 100
Tε = 10:20
nodes = 5
lowε, highε = last(default_params[:ε])
εshock = lowε * ones(T, nodes)

εshockone = copy(εshock)
εshockone[Tε, 1] .= highε

εshockfour = copy(εshock)
εshockfour[Tε, 3] .= highε

εshockonepermanent = copy(εshock)
εshockonepermanent[10:end, 3] .= highε

shocks = Dict(
    "constant" => (εshock, εshock),
    "peripherical" => (εshockfour, εshockone),
    "central" => (εshockone, εshockfour),
    "random" => (nothing, nothing),
    "permanent" => (εshockonepermanent, εshockonepermanent)
)

As, Gs = makestar(nodes)
Al, Gl = makeline(nodes)

for (shockname, shockmatrices) in shocks
    
    println("Simulating $shockname...")

    εs, εg = shockmatrices

    Tₛ = shockname == "random" ? T * 2 : T

    dfagentstar, dfmodelstar, modelstar = plotfromsteadystate(
        As, Gs, Tₛ; εpath=εs, 
        plotpath=joinpath(plotpath, shockname, "star")
    )

    dfagentline, dfmodelline, modelline = plotfromsteadystate(
        Al, Gl, Tₛ; εpath=εg, 
        plotpath=joinpath(plotpath, shockname, "line")
    )
    
end

Plots.resetfontsizes()
println("Done!")