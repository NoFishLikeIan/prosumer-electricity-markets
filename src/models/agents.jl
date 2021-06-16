mutable struct Producer <: AbstractAgent
    id::Int
    pos::Int64

    s::Float64 # Current production
    r::Float64 # Current ramp-up
    
    ψ::Float64 # Forecasting rule
    Ep::Float64 # Price expectation
end

mutable struct Provider <: AbstractAgent
    id::Int
    pos::Int64

    a::Float64 # Forecasting rule slope
    b::Float64 # Forecasting rule intercept
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