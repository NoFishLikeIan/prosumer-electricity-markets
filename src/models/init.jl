function initializemodel(
    A::Matrix{Int64}, parameters::Dict;
    ε₀=10., a₀=1., b₀=-2, s₀=10.,
    seed=1148705
)
    rng = MersenneTwister(seed)

    space = GraphSpace(SimpleGraph(A))
    Nnodes = length(space.s)

    parameters[:R] = repeat([0.0], Nnodes)
    parameters[:p] = repeat([0.0], Nnodes)
    parameters[:X] = repeat([0.0], Nnodes)

    function byids(model::ABM)
        return sort(collect(allids(model)))
    end
    
    model = AgentBasedModel(
        AllAgents, space,
        properties=parameters,
        warn=false, scheduler=byids
    )

    N = parameters[:N]
    M = parameters[:M]
    
    demand = M * ε₀
    supply = N * s₀ 

    U₀ = zeros(size(parameters[:Ψ]))

    for node in 1:Nnodes

        add_agent!(node, Prosumer, model, ε₀)

        provider = add_agent!(
            node, Provider, model, 
            a₀, b₀, 0.
        )
        
        p₀ = p′(demand - supply, provider, model)
        provider.p = p₀

        for _ in 1:N
            ψ₀ = sample(parameters[:Ψ])

            add_agent!(
                node, Producer, model, 
                s₀ * (rand() + 0.5), 0.0, ψ₀, p₀, U₀
            )

        end
        

    end

    return model
end
