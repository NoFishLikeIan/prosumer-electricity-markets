function minimize(fn, s; verbose=true)

    result = optimize(fn, -s, s)

    if verbose && result.minimum > 1e-5
        println("Non-zero result $(result.minimum)")
    end

    return result.minimizer
end

function isbracketing(f, x)
    sign(f(x)) * sign(f(-x)) < 0
end

function rootr(mc, mb, s,  β)
    function f(r)
        benefit = mb(r)
        cost = mc(r) 

        if !isfinite(cost) & !isfinite(benefit)
            return cost
        else
            return cost - benefit * β
        end
    end

    if isbracketing(f, s)
        return find_zero(f, (-s, s))
    else
        try
            return find_zero(f, 0.0)
        catch
            return minimize(r -> -f(r), s)
        end
    end
end

"""
Producer ramp-up function
"""
function r(p, producer::Producer, model)
    s, ψ = producer.s, producer.ψ
    β = model.βprod
    c, ∂c∂s, ∂c∂r = model.c

    mc(r) = ∂c∂r(s, r) * r + c(s, r)

    mb(r) = (∂c∂r(s + r, r) - ∂c∂s(s + r, r)) * r + c(s + r, r) + ψ * p


    return rootr(mc, mb, s, β)
end
