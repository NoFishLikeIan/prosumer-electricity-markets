"""
Make the one prosumer implicit solution of p,
    f(m, p, e) = p (2m + p⋅∂g - 2g) / (m + p⋅∂g - g)
"""
function makesimple(policy; ∂order=12)

    ∂ = central_fdm(∂order, 1)

    g(m, e) = p -> policy(m, p, e)
    gp′(m, p, e) = ∂(g(m, e), p) # ∂g(m, p, e) / ∂p

    function f(m, p, e)
        N = 2 * m + p * gp′(m, p, e) - 2 * g(m, e)(p)

        D = m + p * gp′(m, p, e) - g(m, e)(p)

        return p * N / D

    end
    
    return f
end

function findprice(
    policy, m, e; 
    bounds=[.01, 100.], kwargs...)

    a, b = bounds
    tosolve = makesimple(policy)
    fn = p -> tosolve(m, p, e)

    guess = fn(a) * fn(b) < 0 ? bounds : a + 1.

    p = find_zero(fn, guess)
    
    return p
end