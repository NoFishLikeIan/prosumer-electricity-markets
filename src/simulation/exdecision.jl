"""
Simulate the decision path of a prosumer
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
    ms, xs, policy = zeros(T), zeros(T), zeros(T) # stock level, energy consumption
    U = [0., 0.]  # performance measure for the two policies

    idx = rand((1, 2)) # policy function index

    for (t, p) in enumerate(ps)
        verbose && print("Simulation $t / $T\r")

        policy[t] = idx

        m, e = ms[t], es[t]
        m′ = policies[idx](m, p, e)
        x = (m - m′) / p # Energy consumption

        if t < T ms[t + 1] = m′ end
        xs[t] = x
        
        xc = max(x + e, .01) # FIXME: How can it be negative?

        U[idx] = (1 - ω) * u(xc) + ω * U[idx]
        n = exp(γ * U[idx]) / sum(γ .* U)
        
        change = n < rand(Uniform(-1., 1.)) 

        idx = change ? switch(idx) : idx
    end

    return ms, xs, policy
end