include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/"

Plots.resetfontsizes(); Plots.scalefontsizes(0.8)
default(size=(1000, 800), margin=5Plots.mm) # Plotting defaults

T = 100
nodes = 5
lowε, highε = last(default_params[:ε])
εshock = lowε * ones(T, nodes)

εshockone = copy(εshock)
εshockone[10:13, 1] .= highε

εshockthree = copy(εshock)
εshockthree[10:13, 3] .= highε

shocks = Dict(
    "constant" => (εshock, εshock),
    "peripherical" => (εshockthree, εshockone),
    "central" => (εshockone, εshockthree),
    "random" => (nothing, nothing)
)

As, Gs = makestar(nodes)
Al, Gl = makeline(nodes)


for (shockname, shockmatrices) in shocks
    
    println("Simulating $shockname...")

    εs, εg = shockmatrices

    Tₛ = shockname == "random" ? T * 5 : T

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