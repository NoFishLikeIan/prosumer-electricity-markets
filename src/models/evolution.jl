function p′(p, X, provider::Provider, model)
    β = model.β
    N = model.N

    ∂x = (1 - β) / (β * N * provider.a)
    int = provider.b / provider.a

    return ∂x * X - int - p
end

function agent_step!(prosumer::Prosumer, model)

    Γ, S = model.properties[:ε]

    state = findfirst(==(prosumer.ε), S)

    if rand() > Γ[state, state] # FIXME: Add rng 
        state′ = state == 1 ? 2 : 1 
        prosumer.ε = S[state′]
    end

end

function agent_step!(provider::Provider, model)
    
end

function agent_step!(producer::Producer, model)

end