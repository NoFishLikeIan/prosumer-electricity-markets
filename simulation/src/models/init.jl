function initializemodel(A::Matrix{Int64}, G::Matrix{Int64}, parameters::Dict; seed=1148705)

    if :c ∉ keys(parameters) 
        parameters[:c] = (c, ∂c∂s, ∂c∂r)
    end

    parameters[:rng] = MersenneTwister(seed)
    parameters[:step] = 1

    space = GraphSpace(SimpleGraph(A))
    Nnodes = length(space.s)
    E = map(edgetotuple, edges(space.graph))

    # Bargaining data
    parameters[:P] = Dict(E .=> zeros(length(E)))
    parameters[:Y] = copy(parameters[:P])
    parameters[:G] = G

    # Production data
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

    a₀, b₀ = -1., 1. # FIXME: Is this stable?


    N = parameters[:N]
    M = parameters[:M]


    ε₀ = maximum(parameters[:ε][2]) # Biggest value of possible demand

    r₀ = 0.
    s₀ = M * ε₀ / N # Supply that fixes demand

    for node in 1:Nnodes

        add_agent!(node, Prosumer, model, ε₀)

        p₀ = parameters[:k] # Start at stable value pₜ = k

        add_agent!(node, Provider, model, a₀, b₀, p₀)

        for _ in 1:N
            add_agent!(node, Producer, model, r₀, s₀)
        end
        

    end

    return model
end
