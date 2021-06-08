mutable struct LocalMarket
    producers::Vector{Producer}
    prosumers::Tuple{Int,QuantEcon.MarkovChain} # Size, Chain, State
end

function endowmentstep(endowments::QuantEcon.MarkovChain, current) 
    
    currentstate = findfirst(==(current), endowments.state_values)

    nextε =  simulate(endowments, 2, init=currentstate)[end]

    return convert(Int64, nextε)
end

"""
Compute vectors of r(s, p; ψ)
"""
function producerstep(p::Float64, S::Vector{Float64}, market::LocalMarket)

    R = zeros(size(S))

    for (j, producer) in enumerate(market.producers)
        s = S[j]
        R[j] = r(s, p, producer)
    end 

    return R
end

function prosumerstep(market::LocalMarket)

    M, endowments, currentε = market.prosumers

    nextε = endowmentstep(endowments, currentε)

    return currentε, nextε, M
end