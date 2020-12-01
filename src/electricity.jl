include("network/types.jl")
include("network/trophic.jl")
include("network/simulate.jl")
include("dynamics/energy.jl")

include("utils/plot.jl")

using Random, Plots, Distributions
using LightGraphs, SimpleWeightedGraphs
using DynamicalSystems

seed = 11148705
Random.seed!(seed)

W = [
    0.8 0. 0.5 0.;
    0. 0.8 0. 0.5;
    0.5 0. 0.8 0.5;
    0. 0.5 0.5 0.8
]

N, _ = size(W)

r = [0.8, 0.5, 0.5]
η = [0.1, 0.1, 0.1]
ybar = [.9, .9, .9]

model = HouseholdMarket(W, r, η, ybar, 1)
g = SimpleWeightedDiGraph(W)

x0 = repeat([.5], N)

ds = ContinuousDynamicalSystem(energy_evolve, x0, model)

plotgraph(g, "plots/energy", "lv-network")