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

    R = getjumpindex(model.R, node, N)
    p = getjumpindex(model.p, node, N)

    T = length(p)

    if !all(R .== 0) & !all(p .== 0)

        X = hcat(ones(T), p)
        W = withdecay ? makeW(T) : I

        a, b = inv(X'W * X) * (X'W * R)

        provider.a = min(a, 0.)
        provider.b = max(b, 1.)

    end

end