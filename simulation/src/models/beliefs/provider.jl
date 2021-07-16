ismultipleof(x, m) = x > 0 && (x % m) == 0

"""
Make time exponential decay weighting matrix 
"""
function makeW(T; alpha=0.1)
    W = Array{Float64}(undef, T, T)

    for t₁ in 1:T, t₂ in 1:T
        W[t₁, t₂] = exp(-alpha * abs(t₂ - t₁))
    end

    return W

end

function update_belief!(provider::Provider, model; withdecay=true)

    node = provider.pos
    N = length(model.space.s)

    Rₜ = getjumpindex(model.R, node, N)
    pₜ = getjumpindex(model.p, node, N)
    Xₜ = getjumpindex(model.X, node, N)

    Sₜ = Xₜ .- Rₜ

    T = length(pₜ)

    Ξ = hcat(ones(T), pₜ, Sₜ)
    W = withdecay ? makeW(T) : I

    aₜ, bₜ, cₜ = inv(Ξ'W * Ξ) * (Ξ'W * Rₜ)

    provider.a = aₜ
    provider.b = bₜ
    provider.c = cₜ
    

end