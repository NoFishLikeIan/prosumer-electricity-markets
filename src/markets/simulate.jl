
"""
Simulate the decision path of n heterogenous prosumers
given a simulated price vector
"""
function decisionpath(
    policies::Tuple{Function,Function},
    ps::Vector{Float64}, es::Vector{Float64},
    prosumer::Prosumer, environment::Environment;
    verbose=false
)
    @unpack ω, γ = environment
    @unpack u = prosumer

    T = length(ps)
    cs, xs, policy = zeros(T), zeros(T), zeros(T) # stock level, energy consumption
    U = [0., 0.]  # performance measure for the two policies

    idx = rand((1, 2)) # policy function index

    for (t, p) in enumerate(ps)
        verbose && print("Simulation $t / $T\r")

        policy[t] = idx

        c, e = cs[t], es[t]
        c′ = policies[idx](c, e, p)
        x = (c - c′) / p # Energy consumption

        if t < T cs[t + 1] = c′ end
        xs[t] = x

        U[idx] = (1 - ω) * u(x + e) + ω * U[idx]
        n = exp(γ * U[idx]) / sum(γ .* U)
        
        change = n < rand(Uniform(-1., 1.)) 

        idx = change ? (idx % 2) + 1 : idx
    end

    return cs, xs, policy
end

function simulate(
    prosumer::Prosumer, environment::Environment, T::Int; sizes=(400, 20), kwargs...)

    @unpack ψ₁, ψ₂ = prosumer

    # AR(1) process for prices
    p̄ = 1 / (1 - ψ₁)

    ρ = ψ₁ 
    σ = .01

    ϵ = rand(Normal(0, σ), T)
    p = zeros(Float64, T)
    p[1] = rand(Normal(p̄, σ))
    for t in 2:T p[t] = p̄ * (1 - ρ) + ρ * p[t - 1] + ϵ[t] end

    # Markov process for endowments
    es = QuantEcon.simulate(environment.weather, T)

    # TODO: This simulation uses 1 prosumer
    pess, opt = solvepolicy(sizes, prosumer, environment; tol=1e-2, kwargs...)
    cs, xs, policy = decisionpath((pess, opt), p, es, prosumer, environment; kwargs...)


    return cs, xs, policy, es, p
end