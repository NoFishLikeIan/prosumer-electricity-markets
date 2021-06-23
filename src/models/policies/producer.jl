function minimize(fn, s; verbose=false)

    result = optimize(fn, -s, s)
    return result.minimizer
end

function isbracketing(f, x)
    sign(f(x)) * sign(f(-x)) < 0
end

function rootr(mc, mb, s)
    function f(r)
        benefit = mb(r)
        cost = mc(r) 

        if !isfinite(cost) & !isfinite(benefit)
            return cost
        else
            return cost - benefit
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

        mc(r) = (∂c∂r(s, r) * r + c(s, r)) / β

        mb(r) = (∂c∂r(s + r, r) - ∂c∂s(s + r, r)) * r + c(s + r, r) + ψ * p

        try
            newr = rootr(mc, mb, s)
            return newr

        catch error
            println("β = $β; s = $s; ψ = $ψ; p=$p", '\n')

            throw(error)
        end

    end
