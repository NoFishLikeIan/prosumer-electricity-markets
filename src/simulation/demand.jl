"""
Constructs a demand function for each market based on a policy and wealth distribution

    (e | ...) -> X(p)
"""
function initstatetransition(Grid::ElectricityMarket, ms::Matrix{Float64}, policy::Matrix{Int64}; kwargs...)

    N, M = size(ms)

    function transition(e::Vector{Float64})
        # FIXME: Is this inefficient?
        Xs = Vector{Function}(undef, M) 

        for (j, market) in enumerate(Grid.localmarkets)
            policies, Pros, Env, S = market
            shock = e[j]

            g = [ policies[i] for i in policy[:, j] ] # Function for each agent
            m = ms[:, j] # Wealth levels

            # Constructing aggregate demand function X(p)
            Xs[j] = (p) -> begin
                m′ = [g[i](m[i], p, shock) for i in 1:S]

                x = @. (m - m′) / p
                return sum(x)
            end
        end

        return Xs
    end 

    return transition
end

function initstatetransition(Grid::ElectricityMarket; kwargs...)
    M = length(Grid)
    N = maximum([s for (g, p, e, s) in Grid.localmarkets]) # Biggest market
    
    # Initial wealth levels
    ms = zeros(N, M)
    for (m, market) in enumerate(Grid.localmarkets)
        marketsize = market[end]
        ms[1:marketsize, m] = rand(Uniform(0., 10.), marketsize)
    end

    policy = ones(Int64, N, M) # Initial policy

    return initstatetransition(Grid, ms, policy; kwargs...)
end