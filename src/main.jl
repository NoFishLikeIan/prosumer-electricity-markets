using LightGraphs, LinearAlgebra, SimpleWeightedGraphs

include("utils/plot.jl")

A = [
    0 0.5 0.5;
    0 0 0.8;
    0 0 0
]

g = SimpleWeightedDiGraph(A)

save_graph(g, "plots", "test")