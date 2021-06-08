function simulatelocal(T, market::LocalMarket)
    
    M, chain, _ = market.prosumers
    N = length(market.producers)

    price = 1.1 # FIXME: add price optimization
    εs = simulate(chain, T)

    S = zeros(T, N)
    Rs = zeros(T, N)
    X = zeros(T)

    for t in 2:T

        println("Simulation $t")

        R = producerstep(price, S[t - 1, :], market)
        Rs[t, :] = R

        S[t, :] = S[t - 1, :] .+ R
        X[t] = X[t - 1] + M * (εs[t] - εs[t - 1]) - sum(R)
    end

    return S, X, εs
end
