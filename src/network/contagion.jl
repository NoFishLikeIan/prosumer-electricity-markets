using DynamicalSystems, StaticArrays

State = Array{Float64,1}
Weights = Array{Float64,2}

Parameters = Tuple{Weights,State,State}

@inline @inbounds function evolve(x, p, t)
    W, r, κ = p
    dx = x .* (r - W * x - κ .* x) 

    return SVector{length(dx)}(dx)
    
end
