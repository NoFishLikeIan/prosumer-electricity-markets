MarketSize = Int
Policies = NTuple{2,Function}
LocalMarket = Tuple{Policies,Prosumer,Environment,MarketSize}

mutable struct ElectricityMarket
    A::AbstractMatrix{Int}
    localmarkets::Vector{LocalMarket}
end

function Base.length(G::ElectricityMarket)
    return length(G.localmarkets)
end

