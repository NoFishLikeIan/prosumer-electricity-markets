@with_kw struct Prosumer
    β = 0.99 
    ψ₁ = 0.9
    ψ₂ = 1.1
    d = 1.
    u = x -> d * log(x)
    u′ = x -> d / x
end

@with_kw struct Environment
    weather = MarkovChain([0.9 0.1; 0.1 0.9], [0.1; 1.0])
end

function solvepolicy(
    gridsizes::Tuple{Int,Int},
    prosumer::Prosumer, environment::Environment; kwargs...)

    c′ = endgrid(gridsizes, prosumer, environment; kwargs...)

    return c′
end