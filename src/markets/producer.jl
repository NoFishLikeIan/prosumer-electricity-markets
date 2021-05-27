@with_kw mutable struct Producer
    γ::Float64 = 0.5    # Decay of production
    c::Float64 = 1      # Cost of production ramp up
    β::Float64 = 0.9   # Discount rate
    k::Float64 = 0.2      # Costant in forecasting rules

    ψ::Float64          # Forecast rule
end

"""
Expectations over price
"""
function E(p::Float64, producer::Producer)
    @unpack k, ψ = producer

    return p * ψ + k
end

"""
Producer ramp-up function
"""
function r(x::Float64, p::Float64, producer::Producer)
    p′ = E(p, producer)

    @unpack c, β, γ = producer

    βprod = 1 / β - γ^2 
    scale = inv(1 - γ)

    return scale * (p′ / c - βprod * x)

end

producer = Producer(ψ=1.01)

xs = 0.01:0.05:10
coreprice = producer.k

plot(xs, x -> r(x, coreprice, producer))