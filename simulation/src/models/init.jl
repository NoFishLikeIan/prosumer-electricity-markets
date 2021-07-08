"""
Initialize a model for a given A and G matrix.

Optionally give an εpath
"""
function initializemodel(
    A::Matrix{Int64}, G::Matrix{Int64}, parameters::Dict; 
    εpath=nothing, seed=1148705)

    parameters = copy(parameters) # :(
    
    parameters[:εpath] = εpath # FIXME: Not the best way to do this tbh

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
    parameters[:profit] = repeat([0.0], Nnodes)

    function byids(model::ABM)
        return sort(collect(allids(model)))
    end
    
    model = AgentBasedModel(
        AllAgents, space,
        properties=parameters,
        warn=false, scheduler=byids
    )

    a₀, b₀ = -5., 0.1 # FIXME: Guess from knowing r


    N = parameters[:N]
    M = parameters[:M]


    ε₀ = minimum(parameters[:ε][2]) # Lowest value of possible demand

    r₀ = 0.
    s₀ = M * ε₀ / N # Supply that fixes demand

    for node in 1:Nnodes

        add_agent!(node, Prosumer, model, ε₀)

        p₀ = parameters[:k] + 1e-2 # Start at stable value pₜ = k

        add_agent!(node, Provider, model, a₀, b₀, p₀)

        for _ in 1:N
            add_agent!(node, Producer, model, s₀, r₀)
        end
        

    end

    return model
end
