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

    R = getjumpindex(model.R, node, N)
    p = getjumpindex(model.p, node, N)

    T = length(p)

    X = hcat(ones(T), p)
    W = withdecay ? makeW(T) : I

    a, b = inv(X'W * X) * (X'W * R)

    provider.a = a
    provider.b = b
    

end