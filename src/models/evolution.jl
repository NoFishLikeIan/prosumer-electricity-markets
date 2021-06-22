function agent_step!(prosumer::Prosumer, model)
    Γ, S = model.properties[:ε]

    state = findfirst(==(prosumer.ε), S)

    if rand(model.rng) > Γ[state, state] 
        prosumer.ε = S[flip12(state)]
    end

end

function agent_step!(provider::Provider, model)
    others = agents_in_position(provider, model)

    prosumer = collectfirst(others)
    
    supply = sum(p.s for p in getlocalproducers(provider, model))
    demand = prosumer.ε * model.M
    
    X = demand - supply

    nextprice = p′(X, provider, model)

    # println("Updating provider at $(provider.pos): X = $demand - $supply, $(provider.p) -> $nextprice")

    provider.p = nextprice

end

function agent_step!(producer::Producer, model)
    others = agents_in_position(producer, model)
    _, provider = others

    r′ = r(provider.p, producer, model)
    
    producer.r = r′
    producer.s = max(producer.s + r′, 0.)

end

function model_step!(model)

    for node in 1:length(model.space.s)

        others = agents_in_position(node, model)
        prosumer, provider = others

        R = 0.0
        S = 0.0
        
        for producer in getlocalproducers(node, model)
            update_belief!(producer, model)
            R += producer.r
            S += producer.s
        end

        X = model.M * prosumer.ε - S

        push!(model.p, provider.p)
        push!(model.R, R)
        push!(model.X, X)

        update_belief!(provider, model, node)

    end

end
