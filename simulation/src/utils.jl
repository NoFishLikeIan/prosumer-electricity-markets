function positive(x) 
    isnan(x) ? Inf : max(x, 0.)
end

"""
Assumes as input a list [1, 2, 3, 5, 6] -> [(1, 3), (5, 6)]
"""
function findconsecutive(arr::Vector{Int64})

    if isempty(arr) return [] end

    bounds = []
    current = [first(arr), -1]

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

function safe_find_zero(f; x₀=0., extrema=(-100., 100.))

    lower, upper = extrema

    if sign(f(lower)) * sign(f(upper)) < 0
        find_zero(f, lower, upper)
    else
        find_zero(f, x₀)
    end
    
end

function flip12(idx)
    3 - idx
end

"""
Find a vector of n quantities xᵢ given their sum ∑xᵢ and a vector of n ratios with respect to one of them xᵢ / xₙ (note that xₙ / xₙ = 1 so one entry of the ratios ought to be 1)
"""
function xs_by_sum_ratio(sumX::Float64, ratios::Vector{Float64})
    xₙ = sumX / sum(ratios)
    return xₙ .* ratios
end

function edgetotuple(edge)
    (edge.src, edge.dst)
end

function sortededge(i, j)
    i < j ? (i, j) : (j, i)
end

function δ(i, j)
    i < j ? 1 : -1
    end

function getjumpindex(arr, start, N) 
    return arr[start:N:length(arr)]
end

function roundtillint(num, digits)
    rounded = round(num; digits=digits)
    return digits == 0 ? Int64(rounded) : rounded  
end

function numtostring(num; digits=3) 
    rounded = roundtillint(num, digits) |> string

    if abs(num) < 1.
        afterzero = split(rounded, '.') |> last
        return join(['.', afterzero])
    else
        return rounded
    end
end
