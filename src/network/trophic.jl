using LightGraphs, LinearAlgebra, SimpleWeightedGraphs

IncoherenceLevels = Tuple{Float64,Array{Float64}}

"""
Computes the trophic coherence of a graph as in
McKay et al. 2019
"""
function computeincoherence(graph::SimpleWeightedDiGraph)::IncoherenceLevels
    W = adjacency_matrix(graph)
    w_in = sum(W, dims=1)'
    w_out = sum(W, dims=2)

    # Compute "strength"
    u = reshape(w_in + w_out, (nv(graph),)) 
    v = reshape(w_in - w_out, (nv(graph),)) 

    Λ = Diagonal(u) - W - W'

    # Solve the system Λh = v
    h = Λ \ v

    function confusion(edge::WeightedEdge)
        m, n = src(edge), dst(edge)

        return weight(edge) * (h[n] - h[m] - 1)^2
    end

    F0 = sum(confusion(edge) for edge ∈ edges(graph)) / sum(W)
        
    return F0, h
end