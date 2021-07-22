
function bargainingpower(G::Matrix{Int64})
	inv(2I + G)
end

nodepower(A) = nodepower(A, makeG(A))
function nodepower(A, G)
    g = SimpleGraph(A)
	E = map(edgetotuple, edges(g))

    ρ = bargainingpower(G)

    ∑ρ = sum(ρ, dims=2) ./ sum(ρ)
    
    getnodepower(n) = ∑ρ[findall(e -> n ∈ e, E)] / 2 |> sum

	nodepower = map(getnodepower, vertices(g))

    return nodepower
end

function coherence(A, G)
    powers = nodepower(A, G)   
    μ = mean(powers)
    σ = std(powers)

    return σ / μ
end

"""
Computes the number of levels to reach n elements
"""
function ntokinbtree(n::Int64)::Int64
    k = log2(n + 1)
    if isinteger(k)
        return Int64(k)
    else
        throw(DomainError(k, "Value of k non integer"))
    end
end

isrepresentable(n) = log2(n + 1) |> isinteger


"""
Inverse of ntokinbtree
"""
function ktoninbtree(k::Int64)::Int64
    (2^k - 1)
end

function getpricevariance(dfagent, model)
    g = model.space.graph   

    markets = vertices(g)
    pricevariance = Float64[]

    for node in markets
        _, dfprov, _ = getnodedata(dfagent, node)
        σₚ = std(dfprov.p)

        push!(pricevariance, σₚ)
    end

    return pricevariance
end