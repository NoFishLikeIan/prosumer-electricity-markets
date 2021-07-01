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

    model.step += 1
end
