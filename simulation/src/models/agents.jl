mutable struct Producer <: AbstractAgent
    id::Int
    pos::Int64

    s::Float64 # Current production
    r::Float64 # Current ramp-up
end

mutable struct Provider <: AbstractAgent
    id::Int
    pos::Int64

    α::Float64 # Forecasting rule intercept
    γ::Float64 # ''               slope price
    η::Float64 # ''               slope 
    p::Float64 # Local price
end

mutable struct Prosumer <: AbstractAgent
    id::Int
    pos::Int64

    ε::Float64
end

AllAgents = Union{Producer,Provider,Prosumer}

function getlocalproducers(agent::AllAgents, model)
    others = agents_in_position(agent, model)
    return (a for a in others if a isa Producer)
end

function getlocalproducers(pos::Int64, model)
    others = agents_in_position(pos, model)
    return (a for a in others if a isa Producer)
end