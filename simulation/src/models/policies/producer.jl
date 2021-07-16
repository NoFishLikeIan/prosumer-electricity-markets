"""
Producer ramp-up function assuming softplus costs
"""
function r(s, p, k, β; γ=0.5)
    unitπ = p - k
    
    if unitπ < 0 return -γ * s end
    
    r̅ = √(unitπ)
    ∂β = (1 - β) / β
    
    if inv(∂β) * s < √(unitπ) 
        return r̅ 
    end 

    return ∂β * s - √((∂β * s)^2 - unitπ)
end

function r(p, producer::Producer, model)
    s = producer.s
    β, k = model.βprod, model.k

    return r(s, p, k, β)
end