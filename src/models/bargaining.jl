function getbargsolution(g::SimpleGraph, G::Matrix{Int64}, Xs::Vector{Float64})

    E = map(edgetotuple, edges(g))
    
    Δₓ = [Xs[i] - Xs[j] for (i, j) in E]

    PY = 0.5 * inv(2I + G) * Δₓ

    PYmap = Dict(E .=> PY)
    Y = Dict(e => 0.0 for e in E)
    
    for i in vertices(g)

        basej = last(neighbors(g, i))
        baseedge = sortededge(i, basej)
        baseY = PYmap[baseedge] * δ(i, basej)

        Ei = [sortededge(i, j) for j in neighbors(g, i)]
        ratiosY = [PYmap[e] * δ(i, e[2]) / baseY for e in Ei]

        ∑Y = Xs[i]
        Yi = xs_by_sum_ratio(∑Y, ratiosY)
        Ymap = Dict(Ei .=> Yi)

        for e in Ei
            if Y[e] == 0.0
                Y[e] = Ymap[e]
            end
        end
    end

    P = Dict(e => PYmap[e] / Y[e] for e in E)

    return Y, P
end

function computebargaining(model)
    Nnodes = length(model.space.s)

    latest = Nnodes - 1
    Xs = model.X[end - latest:end]
    g = model.space.graph

    Y, P = getbargsolution(g, model.G, Xs)

    return Y, P
    
end