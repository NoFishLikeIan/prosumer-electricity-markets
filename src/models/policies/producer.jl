function isbracketing(f, a, b)
    sign(f(a)) * sign(f(b)) < 0
end
isbracketing(f, x) = isbracketing(f, -x, x)

function bracketingroots(f, a; δ=100)

    Δa = abs(2 * a)

    for i = 0:δ
        u = a - i * Δa / δ
        if isbracketing(f, u, a)
            return find_zero(f, (u, a))
        end
        if isbracketing(f, -a, -u)
            return find_zero(f, (-a, -u))
        end
    end
    
    throw("Not found")

end

function rootr(mc, mb, s,  β)
    function f(r)
        benefit = mb(r)
        cost = mc(r) 

        if !isfinite(cost)
            cost = sign(cost) * 10e5
        end
        if !isfinite(benefit)
            benefit = sign(benefit) * 10e5
        end

        return cost - benefit * β
    end

    try
        return fzero(f, 0.0)
    catch
        return bracketingroots(f, 100.)
    end

end

"""
Producer ramp-up function
"""
function r(p, producer::Producer, model)
    s, ψ = producer.s, producer.ψ
    β, k = model.βprod, model.k
    c, ∂c∂s, ∂c∂r = model.c

    mc(r) = ∂c∂r(s, r) * r + c(s, r)

    indirect(r) = (∂c∂r(s + r, r) - ∂c∂s(s + r, r)) * r
    mb(r) = indirect(r) + c(s + r, r) + ψ * (p - k)


    try 
        root = rootr(mc, mb, s, β)

        println("   Producer $(producer.pos)-$(producer.id) -> p=$p -> r=$(root) + s=$s")

        return max(-s, root)
    catch error
        print("β = $β; k = $k; ψ = $ψ; p = $p; s = $s")
        throw(error)
    end
end
