"""
Provider's local price setting
"""
function p′(X, S, provider::Provider, model; d=0.8)

    i = provider.pos
    E = keys(model.P) |> collect
    eₘ = E[findfirst(e -> i ∈ e, E)]

    λ = -2 * model.P[eₘ]

    β = model.β
    αₜ, γₜ, ηₜ = provider.α, provider.γ, provider.η

    ∂x = (1 - β) / (β * γₜ)
    intercept = (αₜ + ηₜ * S) / γₜ

    Δp = ∂x * X + intercept - λ

    return provider.p + Δp * d
end
