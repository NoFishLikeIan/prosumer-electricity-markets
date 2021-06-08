@with_kw struct Producer
    β::Float64 = 0.9 # Discount rate
    c::Function = s -> s^3 # Cost of production ramp up
    c′::Function = s -> 3s^2

    ψ::Float64          # Forecast rule / mutable
end

"""
Expectations over price
"""
function E(p::Float64, producer::Producer)
    p * producer.ψ
end

"""
Producer ramp-up function
"""
function r(s::Float64, p::Float64, producer::Producer)
    @unpack c, c′, β = producer

    p′ = E(p, producer)

    foc(r) = c′(s + r) * r - c(s + r) - p′ - c(s) / β 

    return find_zero(foc, 0.)

end