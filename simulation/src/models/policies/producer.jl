"""
Producer ramp-up function assuming softplus costs
"""
function r(s, p, k, β; γ=0.2)
    unitπ = p - k
    
    if unitπ < 0 return -γ * s end
    
    r̅ = √(unitπ)
    βf = (1 - β) / β
    invβf = inv(βf)

    s̲ = invβf * √(unitπ)
    
    if s < s̲ return r̅ end 

    return βf * s - √((2βf * s)^2 - 4unitπ) / 2
end

function r(p, producer::Producer, model)
    s = producer.s
    β, k = model.βprod, model.k

    return r(s, p, k, β)
end