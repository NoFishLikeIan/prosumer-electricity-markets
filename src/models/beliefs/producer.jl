
function update_belief!(producer::Producer, model; γ=0.1)

    _, provider = agents_in_position(producer, model)

    currentsupply, ramp, ψ = producer.s, producer.r, producer.ψ
    p = provider.p

    β = model.βprod

    c = first(model.c)

    # FIXME: Better updating with payoff
    currentstrategy = findfirst(==(ψ), model.Ψ) 

    u = currentsupply * p - c(currentsupply, ramp) * ramp

    producer.U[currentstrategy] = γ * producer.U[currentstrategy] + (1 - γ) * u

    Z = @. exp(β * producer.U)

    probstay = exp(β * producer.U[currentstrategy]) / sum(Z)

    # FIXME: Add rng
    if rand() > probstay
        strategy′ = flip12(currentstrategy)
        producer.ψ = model.Ψ[strategy′]
    end
    
    producer.Ep = producer.ψ * provider.p
    
end
