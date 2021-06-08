mutable struct MarketState
    S::Vector{Float64}
    market::LocalMarket
    producer::Vector{Producer}
end

function MarketState(
    N::Int64, M::Int64, 
    ρ=0.9, ε=10., ε₀=0., # Prosumers
    Ψ=[1.01, 0.99]) # Producers

    S = zeros(N)

    prosumers = (M, makeprosumer(ρ, ε), ε₀)
    producers = [Producer(ψ=sample(Ψ)) for _ in 1:N]
    market = LocalMarket(producers, prosumers)

    return MarketState(S, market, producers)
end 

function step!(t::MarketState)
    S′ = copy(t.S)

    for (j, producer) in enumerate(MarketState.producers)
        s = MarketState.S[j]
        γ = producer.γ
        S′[j] = s * γ + r(s, p, producer)
    end

    # TODO: Update forecasting rule by producers

end

N = M = 10
t₀ = MarketState(N, M)
