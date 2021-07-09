"""
Provider's local price setting
"""
function p′(X, provider::Provider, model; γ=1.)

    i = provider.pos
    E = keys(model.P) |> collect
    eₘ = E[findfirst(e -> i ∈ e, E)]

    λ = -2 * model.P[eₘ]

    β = model.β
    a, b = provider.a, provider.b

    ∂x = (1 - β) / (β * b)

    Δp = ∂x * X + a / b - λ

    return max(provider.p + Δp * γ, 1.)
end
