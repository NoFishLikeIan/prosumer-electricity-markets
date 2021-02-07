using Parameters, QuantEcon
using Base.Threads
using Interpolations, Roots
using Random, Distributions

using Plots, Logging, Printf

Random.seed!(11148705)
Plots.scalefontsizes(.6)

include("utils.jl")
include("plotting/local.jl")
include("markets/local.jl")
include("markets/global.jl")
include("algos/endgrid.jl")
include("simulate.jl")


prosumer = Prosumer(ψ₁=.99, ψ₂=1.01)
environment = Environment(ω=0.5, γ=0.5)


sizes = (600, 100)
pess, opt = solvepolicy(sizes, prosumer, environment; verbose=true, tol=1e-2)

T = 100
ms, xs, policy, es, p = simulate(pess, opt, prosumer, environment, T; verbose=true)

plotsimulation(xs, policy, es)

plotrules(pess, opt, environment, prosumer)
plotg(pess, environment, prosumer)
plotdemand(pess, environment)


Plots.resetfontsizes()
