"""
Provider's local price setting
"""
function p′(X, provider::Provider, model)
    β, k = model.β, model.k
    a, b = provider.a, provider.b

    ∂x = (1 - β) / (β * b)

    Δp = ∂x * X + a / b

    newprice = 10. * cos(model.step / 100) # max(provider.p + Δp * 0.05, 0.)

    println("Prov $(provider.pos): X=$X -> p=$Δp + $(provider.p)")

    return newprice
end