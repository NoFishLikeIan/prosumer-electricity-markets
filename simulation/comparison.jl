include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/energy"

Plots.resetfontsizes(); Plots.scalefontsizes(0.8)
default(size=(1200, 800), margin=5Plots.mm) # Plotting defaults


T = 150
nodes = 3
As, Gs = makestar(nodes)
Al, Gl = makeline(nodes)

begin
    dfagentstar, dfmodelstar, modelstar = plotfromsteadstate(
        As, Gs, T; plotpath=join(plotpath, "smallstar"))

    dfagentline, dfmodelline, modelline = plotfromsteadstate(
        Al, Gl, T; plotpath=join(plotpath, "line"))
end

Plots.resetfontsizes()

