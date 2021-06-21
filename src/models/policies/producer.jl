function minimize(fn; verbose=false)
    result = optimize(x -> fn(first(x)), zeros(1), LBFGS())

    
    if verbose && result.minimum > 1e-5
        minimum = round(result.minimum, digits=2)
        println("Non-zero solution: $(minimum)")
    end

    return first(result.minimizer)
end

"""
Producer ramp-up function
"""
function r(p, producer::Producer, model)
    s, ψ = producer.s, producer.ψ
    β = model.βprod
    c, ∂c∂s, ∂c∂r = model.c

    mc(r) = (∂c∂r(s, r) * r + c(s, r)) / β

    mb(r) = (∂c∂r(s + r, r) - ∂c∂s(s + r, r)) * r + c(s + r, r)

    f(r) = (ψ * p + mb(r) - mc(r))^2

    return minimize(f)
end