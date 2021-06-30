"""
Producer ramp-up function assuming softplus costs
"""
function r(s, p, ψ, k, β)
    unitπ = ψ * p - k

    if unitπ < 0 return -γ * s end

    βf = (1 - β) / β
    invβf = inv(βf)
    
    if s > invβf * √(unitπ)
        return βf * s - 0.5 * √((2βf * s)^2 - 4unitπ)
    else
        return invβf * √(unitπ) - s
    end 
end

function r(p, producer::Producer, model)
    s, ψ = producer.s, producer.ψ
    β, k = model.βprod, model.k

    return r(s, p, ψ, k, β)
end
