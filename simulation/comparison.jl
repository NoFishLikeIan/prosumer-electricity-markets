include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/energy"

Plots.resetfontsizes(); Plots.scalefontsizes(0.8)
default(size=(1000, 800), margin=5Plots.mm) # Plotting defaults


T = 250
nodes = 4
As, Gs = makestar(nodes)
Al, Gl = makeline(nodes)

begin
    dfagentstar, dfmodelstar, modelstar = plotfromsteadystate(
        As, Gs, T; plotpath=joinpath(plotpath, "smallstar"))

    dfagentline, dfmodelline, modelline = plotfromsteadystate(
        Al, Gl, T; plotpath=joinpath(plotpath, "line"))
end

Plots.resetfontsizes()

dfagent, dfmodel, model = dfagentline, dfmodelline, modelline