"""
Provider's local price setting
"""
function p′(X, provider::Provider, model)
    β = model.β
    N = model.N
    a, b = provider.a, provider.b

    ∂x = (1 - β) / (β * N * b)

    newprice = max(∂x * X + a / b + provider.p, 0.)

    return newprice
end