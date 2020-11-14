using Random, Distributions
using LightGraphs, SimpleWeightedGraphs

function er_W(n::Int, p::Float64, seed::Int)
    A = adjacency_matrix(erdos_renyi(n, p, is_directed=true, seed=seed))

    return W .* rand(n, n)
end

function dynamicsonerdos(
    N::Int, p::Float64, f, init_params;
    x0=ones(N), seed::Int=11148705
)

    A = adjacency_matrix(erdos_renyi(N, p, is_directed=true, seed=seed))
    W = A .* rand(N, N)
    g = SimpleWeightedDiGraph(W)

    ds = ContinuousDynamicalSystem(f, x0, params)

    return ds, g
end