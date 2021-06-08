using Parameters, QuantEcon
using Base.Threads
using FiniteDifferences
using Random, Distributions
using LinearAlgebra
using Roots

using Plots, Logging, Printf
using LightGraphs, GraphPlot
using StatsPlots, DataFrames

Random.seed!(11148705)

include("utils.jl")

include("markets/prosumer.jl")
include("markets/producer.jl")
include("markets/supply.jl")

include("markets/global.jl")
include("markets/gridfirm.jl")

include("simulation/simutils.jl")
include("simulation/simulate.jl")


M = 10 # Number of prosumers
N = 10 # Number of producers

Ψ = [0.8]

N = M = 10

producers = [Producer(ψ=0.8) for _ in 1:N]
prosumers = (M, makeprosumer(0.9, 5.), 1)  

market = LocalMarket(producers, prosumers)

T = 100
S, X, ε = simulatelocal(T, market)
prod = sum(S, dims=2)

plot(1:T, X, c="red")
plot!(twinx(), 1:T, M .* ε, c="blue", alpha=0.5)