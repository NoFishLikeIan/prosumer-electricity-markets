"""
Provider's local price setting
"""
function p′(X, provider::Provider, model; γ=.4)

    i = provider.pos
    E = keys(model.P) |> collect
    eₘ = E[findfirst(e -> i ∈ e, E)]

    λ = -2 * model.P[eₘ]

    β = model.β
    a, b = provider.a, provider.b

    ∂x = (1 - β) / (β * b)

    Δp = ∂x * X + a / b - λ

    return provider.p + Δp * γ
end
