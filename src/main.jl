using Parameters, QuantEcon
using Base.Threads
using Interpolations, Roots
using Random, Distributions

using Plots, Logging, Printf

Random.seed!(11148705)
Plots.scalefontsizes(.6)

include("utils.jl")
include("plotting.jl")
include("markets/local.jl")
include("algos/endgrid.jl")
include("markets/simulate.jl")


prosumer = Prosumer(ψ₁=.99, ψ₂=1.01)
environment = Environment(ω=0.5, γ=0.5)


T = 200
cs, xs, policy, es, p = simulate(prosumer, environment, T; verbose=true)

plotsimulation(xs, policy, es)

sizes = (400, 10)
pess, opt = solvepolicy(sizes, prosumer, environment; verbose=true, tol=1e-2)

plotrules(pess, opt, environment, prosumer)
plotg(pess, environment, prosumer)
plotdemand(pess, environment)

Plots.resetfontsizes()