mutable struct Producer <: AbstractAgent
    id::Int
    pos::Int64

    s::Float64 # Current production
    ψ::Float64 # Forecasting rule
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