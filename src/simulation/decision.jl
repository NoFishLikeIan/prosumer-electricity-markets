"""
Simulate the decision path of a prosumer given a simulated price vector
"""
function decisionpath(
    policies::Tuple{Function,Function},
    ps::Vector{Float64}, es::Vector{Float64},
    prosumer::Prosumer, environment::Environment;
    kwargs...)

    getprice(pol, m, e, t) = ps[t]

    return decisionpath(policies, getprice, es, prosumer, environment; kwargs...)
end

"""
Simulate the decision path of an agent given an endogenous price mechanism
"""
function decisionpath(
    policies::Tuple{Function,Function},
    getprice::Function, es::Vector{Float64}, 
    prosumer::Prosumer, environment::Environment;
    N=1, verbose=false)
    
    @unpack ω, γ = environment
    @unpack u = prosumer

    T = length(es)

    ms, xs = zeros(T, N), zeros(T, N) # cash level and demand 
    policy = zeros(Int, T, N) #  agent types
    ps = zeros(T) # realized prices

    ms[1, :] = rand(Uniform(0., 10.), N) # initial cash level

    U = zeros(2, N)  # performance measure for the two policies

    idx = rand((1, 2), N) # policy function index

    for (t, e) in enumerate(es)
        verbose && print("Simulation $t / $T\r")

        policy[t, :] = idx

        # Iterate over each agent
        for i in 1:N

            jdx = idx[i]

            gₜ = policies[jdx]

            m = ms[t, i]
            p = getprice(gₜ, m, e, t)

            m′ = gₜ(m, p, e)
            x = (m - m′) / p # Energy consumption

            if t < T ms[t + 1, i] = m′ end
            xs[t, i] = x
            ps[t] = p
            
            xc = max(x + e, .01) # FIXME: How can it be negative?

            U[jdx, i] = (1 - ω) * u(xc) + ω * U[jdx, i]
            n = exp(γ * U[jdx, i]) / sum(γ .* U)
            
            change = n < rand(Uniform(-1., 1.)) 

            idx[i] = change ? switch(jdx) : jdx
        end
    end

    return ms, xs, policy, ps
end