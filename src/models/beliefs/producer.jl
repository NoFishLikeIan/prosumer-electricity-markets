
function update_belief!(producer::Producer, model; γ=0.1)

    _, provider = agents_in_position(producer, model)

    currentsupply, ramp, ψ = producer.s, producer.r, producer.ψ
    p = provider.p

    β = model.βprod
    k = model.k

    c = first(model.c)

    currentstrategy = findfirst(==(ψ), model.Ψ) 

    u = currentsupply * (p - k) - c(currentsupply, ramp) * ramp

    producer.U[currentstrategy] = γ * producer.U[currentstrategy] + (1 - γ) * u

    Z = @. exp(β * producer.U)

    probstay = exp(β * producer.U[currentstrategy]) / sum(Z)

    # FIXME: Add rng
    if rand(model.rng) > probstay
        strategy′ = flip12(currentstrategy)
        producer.ψ = model.Ψ[strategy′]
    end
    
    producer.Ep = producer.ψ * provider.p
    
end
