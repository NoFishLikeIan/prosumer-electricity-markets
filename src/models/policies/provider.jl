"""
Provider's local price setting
"""
function p′(X, provider::Provider, model)
    β = model.β
    N = model.N
    a, b = provider.a, provider.b

    ∂x = (1 - β) / (β * N * a)

    return max(∂x * X + b / a + provider.p, 0.)
end