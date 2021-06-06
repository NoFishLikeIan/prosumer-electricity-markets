using Parameters, QuantEcon
using Base.Threads
using FiniteDifferences
using Random, Distributions
using LinearAlgebra

using Plots, Logging, Printf
using LightGraphs, GraphPlot
using StatsPlots, DataFrames

Random.seed!(11148705)

include("utils.jl")

include("markets/prosumer.jl")
include("markets/producer.jl")
include("markets/supply.jl")
include("markets/simulate.jl")

include("markets/global.jl")
include("markets/gridfirm.jl")

include("simulation/simutils.jl")


M = 10 # Number of prosumers
N = 10 # Number of producers

Ψ = [1.01, 0.99]

prosumers = (M, makeprosumer(0.9, 10.), 1)
producers = [Producer(ψ=sample(Ψ)) for n in 1:N]
market = LocalMarket(producers, prosumers)
