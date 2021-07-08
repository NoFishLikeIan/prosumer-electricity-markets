function agent_step!(prosumer::Prosumer, model)
    if !isnothing(model.εpath) # If given predefined path
        
        n = prosumer.pos
        t = model.step

        prosumer.ε = model.εpath[t, n]
        
    else    
        Γ, S = model.properties[:ε]
    
        state = findfirst(==(prosumer.ε), S)
    
        if rand(model.rng) > Γ[state, state] 
            prosumer.ε = S[flip12(state)]
        end
    end


end

function agent_step!(provider::Provider, model)
    others = agents_in_position(provider, model)

    prosumer = first(others)
    
    supply = sum(p.s for p in getlocalproducers(provider, model))
    demand = prosumer.ε * model.M
    
    X = demand - supply

    nextprice = p′(X, provider, model)

    provider.p = nextprice

end

function agent_step!(producer::Producer, model)
    others = agents_in_position(producer, model)
    _, provider = others

    r′ = r(provider.p, producer, model)
    
    producer.r = r′
    producer.s = max(producer.s + r′, 0.)

end

function πprovider(X, provider, model)
    trade = 0.

    for (edge, Yⱼ) in model.Y
        i, j = edge
        Pⱼ = model.P[edge]

        if i == provider.pos
            trade += Yⱼ * Pⱼ
        elseif j == provider.pos
            trade += -Yⱼ * Pⱼ
        end
    end
    
    return X * provider.p - trade
end

function model_step!(model)

    for node in 1:length(model.space.s)

        others = agents_in_position(node, model)
        prosumer, provider = others

        R = sum(p.r for p in getlocalproducers(node, model))
        supply = sum(p.s for p in getlocalproducers(node, model))

        X = model.M * prosumer.ε - supply

        push!(model.p, provider.p)
        push!(model.R, R)
        push!(model.X, X)

        if model.step > 10
            update_belief!(provider, model)
        end

    end

    Y, P = computebargaining(model)

    model.P = P 
    model.Y = Y 

    # Profits have to be computed after P and Y
    for node in 1:length(model.space.s)

        others = agents_in_position(node, model)
        prosumer, provider = others

        supply = sum(p.s for p in getlocalproducers(node, model))

        X = model.M * prosumer.ε - supply

        push!(model.profit, πprovider(X, provider, model))

    end
    
    model.step += 1
    print("Simulation, t = $(model.step)", '\r')
end
