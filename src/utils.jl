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

function cartesian(x, y)
    return collect.(Iterators.product(x, y))
end

cartesianfromsize(Ns...) = collect(Iterators.product((1:N for N in Ns)...))

function positive(x) 
    isnan(x) ? Inf : max(x, 0.)
end

"""
Assumes as input a list [1, 2, 3, 5, 6] -> [(1, 3), (5, 6)]
"""
function findconsecutive(arr::Vector{Int64})
    bounds = []
    current = [1, -1]

    N = length(arr)

    for (i, e) in enumerate(arr)
        if i == N
            current[2] = e
            push!(bounds, current)

            return bounds
        elseif arr[i + 1] != e + 1 
            current[2] = e
            push!(bounds, current)

            current = [arr[i + 1], -1]
        end
end

return []
end

function collectfirst(itr)
    collect(Base.Iterators.take(itr, 1))[1]
end

function safe_find_zero(f, x₀; fallback=0.0)
    try
        find_zero(f, x₀)
    catch
        fallback
    end
end