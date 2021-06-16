
function update_belief!(producer::Producer, model)

    _, provider = agents_in_position(producer, model)

    # FIXME: Better updating with payoff
    ψₗ, ψᵤ = model.Ψ
    producer.ψ = provider.p - producer.Ep > 0 ? ψᵤ : ψₗ

    producer.Ep =  producer.ψ *  provider.p

end
