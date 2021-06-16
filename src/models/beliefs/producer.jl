
function update_belief!(producer::Producer, model)

    _, provider = agents_in_position(producer, model)

    currentsupply, ramp, ψ = producer.s, producer.r, producer.ψ
    p = provider.p

    # FIXME: Better updating with payoff
    currentstrategy = findfirst(==(ψ), model.Ψ) 

    u = currentsupply * p - model.c(currentsupply) * ramp

    producer.U[currentstrategy] += u

    probstay = exp(producer.U[currentstrategy]) / sum(exp.(producer.U))

    # FIXME: Add rng
    if rand() > probstay
        strategy′ = flip12(currentstrategy)
        producer.ψ = model.Ψ[strategy′]
    end
    
    producer.Ep = producer.ψ * provider.p
    
end
