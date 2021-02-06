switch(idx) = (idx % 2) + 1 # 1 -> 2 and 2 -> 1

"""
Simulate the decision path of n heterogenous prosumers
given a simulated price vector
"""
function decisionpath(
    policies::Tuple{Function,Function},
    ps::Vector{Float64}, es::Vector{Float64},
    prosumer::Prosumer, environment::Environment;
    verbose=false)
    
    @unpack ω, γ = environment
    @unpack u = prosumer

    T = length(ps)
    cs, xs, policy = zeros(T), zeros(T), zeros(T) # stock level, energy consumption
    U = [0., 0.]  # performance measure for the two policies

    idx = rand((1, 2)) # policy function index

    for (t, p) in enumerate(ps)
        verbose && print("Simulation $t / $T\r")

        policy[t] = idx

        m, e = cs[t], es[t]
        m′ = policies[idx](m, e, p)
        x = (m - m′) / p # Energy consumption

        if t < T cs[t + 1] = m′ end
        xs[t] = x
        
        xc = max(x + e, .01) # FIXME: How can it be negative?

        U[idx] = (1 - ω) * u(xc) + ω * U[idx]
        n = exp(γ * U[idx]) / sum(γ .* U)
        
        change = n < rand(Uniform(-1., 1.)) 

        idx = change ? switch(idx) : idx
    end

    return cs, xs, policy
end

function simulate(
    prosumer::Prosumer, environment::Environment, T::Int; sizes=(400, 20), kwargs...)

    pess, opt = solvepolicy(sizes, prosumer, environment; tol=1e-2, kwargs...)

    return simulate(pess, opt, prosumer, environment, T; sizes=sizes, kwargs...)

end

function simulate(
    pess::Function, opt::Function,
    prosumer::Prosumer, environment::Environment, T::Int; sizes=(400, 20), p̄=20., kwargs...)

    @unpack ψ₁, ψ₂ = prosumer

    ρ = ψ₁ 
    σ = .01

    ϵ = rand(Normal(0, σ), T)
    p = zeros(Float64, T)
    p[1] = rand(Normal(p̄, σ))
    for t in 2:T p[t] = p̄ * (1 - ρ) + ρ * p[t - 1] + ϵ[t] end

    # Markov process for endowments
    es = QuantEcon.simulate(environment.weather, T)

    # TODO: This simulation uses 1 prosumer
    
    ms, xs, policy = decisionpath((pess, opt), p, es, prosumer, environment; kwargs...)


    return ms, xs, policy, es, p
end