function fromVtoFn(x::Vector{Float64}, f::Vector{Float64})

    intp = LinearInterpolation((x,), f, extrapolation_bc=(Linear(),))

    function fn(x::Float64) intp(x) end

    return fn
    
end

"""
Takes a matrix m and vectors vs yields the linear interpolation:
    f(vs...) = m
"""
function fromMtoFn(m, xs...)
    intp = LinearInterpolation(
        (xs...,), m, 
        extrapolation_bc=Linear())

    function fn(xs::Float64...) intp(xs...) end
    function fn(v::Vector{Float64}) return fn(v...) end

    return fn
end
