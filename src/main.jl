# -- Top level includes, they should only appear here
include("network/types.jl")
include("network/trophic.jl")
include("network/simulate.jl")
include("dynamics/lotkavolterra.jl")

include("utils/plot.jl")
# --

using Random, Plots, Distributions
seed = 11148705
Random.seed!(seed)

function presentations_plot()
    N, p = 5, .5
    r = rand(Uniform(0.5, 0.7), N)
    κ = rand(Uniform(0.5, 0.7), N)
    
    ds, graph = dynamicsonerdos(
        N, p,
        lv_evolve,
        (r, κ);
        x0=rand(Uniform(0.2, 0.8), N)
    )

    plotgraph(graph, "plots/presentations", "lv-network")

    coherent_W = [
        0. 1. 0.;
        0. 0. 1.;
        1. 0. 0.
    ]

    graph = SimpleWeightedDiGraph(coherent_W)
    plotgraph(
        graph, "plots/presentations", "lv-network-coherent", 
        coherence=(1, [0., 0., 0.]))

    coherent_W = [
        0. 1. 0.;
        0. 0. 1.;
        0. 0. 0.
    ]

    graph = SimpleWeightedDiGraph(coherent_W)

    plotgraph(
        graph, "plots/presentations", "lv-network-incoherent", 
        coherence=(0, [0., 0.5, 1.]))

    N, p = 25, .2
    r = rand(Uniform(0.5, 0.7), N)
    κ = rand(Uniform(0.5, 0.7), N)
    
    ds, graph = dynamicsonerdos(
        N, p,
        lv_evolve,
        (r, κ);
        x0=rand(Uniform(0.2, 0.8), N)
    )

    plotgraph(graph, "plots/presentations", "lv-network-big")

    return graph
end

function dynamical_presentation(graph)
    N = nv(graph)

    W = adjacency_matrix(graph)
    
    simple_eom(x, p, t) = 1 / p[1] * SVector{N}(x'W)

    x0 = SVector{N}(ones(N))
    
    function sim_norm(r)
        ds = DiscreteDynamicalSystem(simple_eom, x0, [r])
        sim = trajectory(ds, 100)

        return [norm(row) for row in eachrow(Matrix(sim))]
    end

    plot(title="Simulation", xaxis="t", yaxis="||x(t)||", dpi=400, legend=:topright)
    ts = 0:100

    rs = range(2.4, 3., length=5)

    for (n, r) in enumerate(rs)
        plot!(ts, sim_norm(r), label="r = $r")
    end

    savefig("plots/presentations/dynamics.png")

end

function plot_stability(graph)
    W = adjacency_matrix(graph)
    F0, _ = computeincoherence(graph)

    threshold = exp(0.5 * (1 - 1 / F0)) * norm(W)
    converges = r -> log(threshold / r)
    rs = range(0.01, 3., length=100)

    plot(
        rs, converges.(rs), 
        title="Convergence of log ||x(t)|| / t", 
        label="log(ρ / r)",
        xlabel="r", color="blue")

    savefig("plots/presentations/convergence.png")
end


W = (rand(10, 10) .> .6) .* rand(10, 10)  
graph = SimpleWeightedDiGraph(W)
plotgraph(graph, "plots/presentations", "electricity", withlabel=false)

