makeprosumer(ρ::Float64, ε::Float64) = makeprosumer(ρ, [ε, -ε])
function makeprosumer(ρ::Float64, states::Vector{Float64})::QuantEcon.MarkovChain
    P = [
        ρ 1 - ρ;
        1 - ρ ρ
    ]

    return MarkovChain(P, states)
end