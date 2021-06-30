"""
Provider's local price setting
"""
function p′(X, provider::Provider, model)
    λ = -2 * first(values(model.P))

    β, k = model.β, model.k
    a, b = provider.a, provider.b

    ∂x = (1 - β) / (β * b)

    Δp = ∂x * X + a / b - λ

    return max(provider.p + Δp, 0.)
end