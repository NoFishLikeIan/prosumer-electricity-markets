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

function solvepolicy(prosumer::Prosumer, environment::Environment, p::Float64; n_steps=100, c̄=10., kwargs...)
    gridsizes = (100, 10)
    c′ = policyiter(gridsizes, prosumer, environment; kwargs...)

end