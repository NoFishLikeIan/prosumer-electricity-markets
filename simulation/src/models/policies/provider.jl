"""
Provider's local price setting
"""
function p′(X, provider::Provider, model; γ=1.)
    λ = -2 * first(values(model.P))

    β = model.β
    a, b = provider.a, provider.b

    ∂x = (1 - β) / (β * b)

    Δp = ∂x * X + a / b - λ

    return max(provider.p + Δp * γ, 0.)
end
