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