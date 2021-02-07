"""
Make the one prosumer implicit solution of p,

    f(m, p, e) = ∂g / (g - m) - 2
"""
function makesimple(policy; order=12)

    ∂ = central_fdm(order, 1)

    g(m, e) = p -> policy(m, p, e)
    gp′(m, p, e) = ∂(g(m, e), p) # ∂g(m, p, e) / ∂p

    f(m, p, e) = gp′(m, p, e) / (policy(m, p, e) - m) - 2.

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