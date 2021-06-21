"""
Producer ramp-up function
"""
function r(p, producer::Producer, model)
    s, ψ = producer.s, producer.ψ
    β = model.βprod
    c, ∂c∂s, ∂c∂r = model.c

    mc(r) = (∂c∂r(s, r) * r + c(s, r)) / β

    mb(r) = (∂c∂r(s + r, r) - ∂c∂s(s + r, r)) * r + c(s + r, r)

    f(r) = ψ * p + mb(r) - mc(r)

    return safe_find_zero(f)
end