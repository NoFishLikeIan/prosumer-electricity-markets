function agent_step!(prosumer::Prosumer, model)

    Γ, S = model.properties[:ε]

    state = findfirst(==(prosumer.ε), S)

    # FIXME: Add rng
    if rand() > Γ[state, state] 
        state′ = state == 1 ? 2 : 1 
        prosumer.ε = S[state′]
    end

end

function agent_step!(provider::Provider, model)
    others = agents_in_position(provider, model)

    prosumer = collectfirst(others)
    
    supply = sum(p.s for p in getlocalproducers(provider, model))
    demand = prosumer.ε * model.M
    
    X = demand - supply

    provider.p = p′(X, provider, model)

end

function agent_step!(producer::Producer, model)
    others = agents_in_position(producer, model)
    _, provider = others

    r′ = r(provider.p, producer, model)
    producer.r = r′
    producer.s = producer.s + r′
end

function model_step!(model)

end
