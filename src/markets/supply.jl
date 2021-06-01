mutable struct LocalMarket
    producers::Vector{Producer}
    prosumers::Tuple{Int,QuantEcon.MarkovChain,Int} # Size, Chain, State
end

"""
Compute supply of a local market
"""
function S′(p::Real, S::Vector{Float64}, producers::Vector{Producer})
    γ = producers[end].γ

    R = sum(r(S[i], p, prod) for (i, prod) in enumerate(producers))

    return γ * sum(S) + R

end


function X(p::Float64, S::Vector{Float64}, market::LocalMarket)
    @unpack producers, prosumers = market

    M, endowments, εₒ = prosumers
    ε = simulate(endowments, 1, init=εₒ)[1]

    return M * ε - S′(p, S, producers)
end