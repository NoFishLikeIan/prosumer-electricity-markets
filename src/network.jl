function getX(model)
    N = length(model.space.s)
    T = length(model.X) ÷ N

    return reshape(model.X, N, T)'
end

function getp(dfagent)
    prices = dfagent.p[dfagent.agent_type .== :Provider]

    N = length(model.space.s)
    T = length(prices) ÷ N


    return reshape(prices, N, T)'

end

function constructΔY(X, p, graph)
    E = edges(graph)

    T = size(X, 1)
    Δ = zeros(T, length(E))
    Y = zeros(T, length(E))

    for (i, e) in enumerate(E)
        Δ[:, i] = @. X[:, e.src] * p[:, e.src] - X[:, e.dst] * p[:, e.dst]   
        
        Y[:, i] = @. X[:, e.src] - X[:, e.dst]
    end

    return Δ, Y
end

function networkprice(dfagent, model)
    X = getX(model)
    p = getp(dfagent)
    
    graph = model.space.graph
    G = model.G

    D = inv(2I + G)

    Δ, Y = constructΔY(X, p, graph)
    PY = Δ * D

    return PY ./ Y

end