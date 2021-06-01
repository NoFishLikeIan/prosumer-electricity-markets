function makelocalsimulation(
    N::Int64, M::Int64, 
    ρ=0.9, ε=10., ε₀=0, # Prosumers
    Ψ=[1.01, 0.99] # Producers
)

    S = zeros(N)

    prosumers = (M, makeprosumer(ρ, ε), ε₀)
    producers = [Producer(ψ=sample(Ψ)) for n in 1:N]
    market = LocalMarket(producers, prosumers)

    function step(p)
        

    end


    return step
end