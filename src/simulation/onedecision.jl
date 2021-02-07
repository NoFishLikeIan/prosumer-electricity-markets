# TODO: One function to do both exogenous and endogenous simulation

"""
Simulate the decision path of an agent given an
endogenous price
"""
function decisionpath(
    policies::Tuple{Function,Function},
    getprice::Function, es::Vector{Float64}, 
    prosumer::Prosumer, environment::Environment;
    verbose=false)
    
    @unpack ω, γ = environment
    @unpack u = prosumer

    T = length(es)

    ms, xs, policy, ps = zeros(T), zeros(T), zeros(T), zeros(T) # stock level, energy consumption, and policy
    U = [0., 0.]  # performance measure for the two policies

    idx = rand((1, 2)) # policy function index

    for (t, e) in enumerate(es)
        verbose && print("Simulation $t / $T\r")

        policy[t] = idx

        currentpolicy = policies[idx]

        m, e = ms[t], es[t]
        p = getprice(currentpolicy, m, e)

        m′ = currentpolicy(m, p, e)
        x = (m - m′) / p # Energy consumption

        if t < T ms[t + 1] = m′ end
        xs[t] = x
        ps[t] = p
        
        xc = max(x + e, .01) # FIXME: How can it be negative?

        U[idx] = (1 - ω) * u(xc) + ω * U[idx]
        n = exp(γ * U[idx]) / sum(γ .* U)
        
        change = n < rand(Uniform(-1., 1.)) 

        idx = change ? switch(idx) : idx
    end

    return ms, xs, policy, ps
end