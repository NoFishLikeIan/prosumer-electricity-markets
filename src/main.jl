# -- Top level includes, they should only appear here
include("network/types.jl")
include("network/trophic.jl")

include("utils/plot.jl")
# --

using Random
seed = 11148705
Random.seed!(seed)

n, p = 9, .5

A = adjacency_matrix(erdos_renyi(n, p, is_directed=true, seed=seed))
W = A .* rand(n, n)

g = SimpleWeightedDiGraph(W)

plotgraph(g, "plots", "random")

incoherence, levels = computeincoherence(g)
