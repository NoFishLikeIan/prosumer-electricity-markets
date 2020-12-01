using StaticArrays, Parameters

State = Array{Float64,1}
Weights = Array{Float64,2}

struct HouseholdMarket
    W::Array{Float64,2}
    r::Array{Float64,1}
    η::Array{Float64,1}
    ybar::Array{Float64,1}
    p::Float64
end

@inline @inbounds function energy_evolve(y, params::HouseholdMarket, t)
    """
    Network energy demand
    """
    @unpack W, r, η, p, ybar = params
    dy = nothing
    @. dy = r - p * W * (1 - y) + η * y - ybar

    return SVector{length(dy)}(dy)
    
end
