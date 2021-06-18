"""
Producer ramp-up function
"""
function r(p, producer::Producer, model)
    s, ψ = producer.s, producer.ψ
    β, c, c′ = model.β, model.c, model.c′

    mb = ψ * p - c(s) / β 

    f(r) = r * c′(s + r) - c(s + r) - mb

    return safe_find_zero(f)
end