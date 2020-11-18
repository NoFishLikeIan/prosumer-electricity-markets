using Random, Distributions

using LightGraphs, SimpleWeightedGraphs

using DynamicalSystems

function er_W(n::Int, p::Float64, seed::Int)
    A = adjacency_matrix(erdos_renyi(n, p, is_directed=true, seed=seed))

    return W .* rand(n, n)
end

function dynamicsonerdos(
    N::Int, p::Float64, f, init_params;
    x0=nothing, seed::Int=11148705
)

    x0 =  SVector{N}(isnothing(x0) ? ones(N) : x0)

    A = adjacency_matrix(erdos_renyi(N, p, is_directed=true, seed=seed))
    W = A .* rand(N, N)
    g = SimpleWeightedDiGraph(W)

    params = (W, init_params...)

    ds = ContinuousDynamicalSystem(f, x0, params)

    return ds, g
end