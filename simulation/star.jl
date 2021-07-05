using Plots
using DataFrames

include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/energy/smallstar/"

doplot = false
T = 150
A, G = makestar(7)

begin
    Plots.resetfontsizes(); Plots.scalefontsizes(0.8)
    default(size=(1200, 800), margin=5Plots.mm)

    dfagent, dfmodel, model = plotfromsteadstate(A, G, T; plotpath=plotpath)

    Plots.resetfontsizes()
end