function initializemodel(
    A::Matrix{Int64}, parameters::Dict;
    ε₀=10., a₀=1., b₀=-10., s₀=1.,
    seed=1148705
)
    rng = MersenneTwister(seed)

    space = GraphSpace(SimpleGraph(A))
    
    model = AgentBasedModel(
        AllAgents, space,
        properties=parameters
    )

    Nnodes = length(model.space.s)

    N = parameters[:N]
    M = parameters[:M]
    
    demand = M * ε₀
    supply = N * s₀ 

    for node in 1:Nnodes
        add_agent!(node, Prosumer, model, ε₀)

        provider = add_agent!(
            node, Provider, model, 
            a₀, b₀, 0.
        )
        
        p₀ = p′(demand - supply, provider, model)
        provider.p = p₀

        for n in 1:N
            ψ₀ = sample(parameters[:Ψ])

            add_agent!(
                node, Producer, model, 
                s₀, 0.0, ψ₀, p₀
            )

        end
        

    end

    return model
end
