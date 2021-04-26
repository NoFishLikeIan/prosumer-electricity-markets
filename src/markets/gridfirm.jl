"""
Constructs the optimal behavior towards the local market with numerical derivative

p + [X / X′](p)
"""
function optimumlocal(X::Function)
    ∂ = central_fdm(12, 1)
    X′(p) = ∂(X, p)

    function rhs(p)
        p + X(p) / X′(p)
    end
end

"""
Constructs the optimal behavior towards an energy provider

X′(p) ⋅ (p - c) + X(p) = 0
"""
function optimumprovider(X::Function)
    ∂ = central_fdm(12, 1)
    X′(p) = ∂(X, p)

    function fo(p, c)
        X′(p) * (p - c) + X(p)
    end

end