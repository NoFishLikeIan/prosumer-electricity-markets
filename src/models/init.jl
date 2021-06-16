function initializemodel(
    A::Matrix{Int64}, parameters::Dict;
    ε₀=10., a₀=1., b₀=-10., s₀=1., ψ₀=1.,
    seed=1148705
)
    rng = MersenneTwister(seed)

    space = GraphSpace(SimpleGraph(A))
    
    model = AgentBasedModel(
        AllAgents, space,
        properties=parameters
    )

    N = parameters[:N]
    M = parameters[:M]

    
    demand = M * ε₀
    supply = N * s₀ 

    for node in 1:size(A, 1)
        add_agent!(node, Prosumer, model, ε₀)

        provider = add_agent!(node, Provider, model, a₀, b₀, 0.)
        
        p₀ = p′(0., demand - supply, provider, model)
        provider.p = p₀

        for n in 1:N
            add_agent!(node, Producer, model, s₀, ψ₀)
        end
        

    end

    return model
end