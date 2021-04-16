MarketSize = Int
Policies = NTuple{2,Function}
LocalMarket = Tuple{Policies,Prosumer,Environment,MarketSize}

struct ElectricityMarket
    A::AbstractMatrix{Int}
    localmarkets::Vector{LocalMarket}
end

function Base.length(G::ElectricityMarket)
    return length(G.localmarkets)
end


# Example
A = [
    0 1;
    1 0;
]

N, N = size(A)
marketsize = 10

setups = [
    (
        Prosumer(ψ₁=.95, ψ₂=1.01), 
        Environment(ω=(0.3 + i / 10), γ=0.5), 
        marketsize
    ) for i in 1:N
]

polsolve = (p, e) -> solvepolicy((600, 100), p, e; verbose=true)

localmarkets = [(polsolve(p, e), p, e, s) for (p, e, s) in setups]


Grid = ElectricityMarket(A, localmarkets)

f = initstatetransition(Grid)

X₁, X₂ = f([1.01, 0.99])

if false
    ps = range(0., 10., length=100)
    plot()
    for (n, X) in enumerate(f([1.01, 0.99]))
        envelope = optimumlocal(X)
        plot!(ps, envelope, label=n)
    end

    savefig("test.png")

    plot(ps, X₂)

    envelope = optimumlocal(X₂)

    plot(ps, envelope)
end