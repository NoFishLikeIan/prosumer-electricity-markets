"""
Provider's local price setting
"""
function p′(X, provider::Provider, model)
    β = model.β
    N = model.N
    a, b = provider.a, provider.b

    ∂x = (1 - β) / (β * N * b)

    Δp = ∂x * X + a / b

    newprice = max(provider.p + Δp, 0.1)

    return newprice
end