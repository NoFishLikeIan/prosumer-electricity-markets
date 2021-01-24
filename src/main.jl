using Parameters, QuantEcon
using Base.Threads
using Interpolations, Roots
using Random, Distributions

Random.seed!(11148705)
Plots.scalefontsizes(.6)


using Plots, Logging, Printf

include("utils.jl")
include("plotting.jl")
include("markets/local.jl")
include("algos/endgrid.jl")
include("markets/simulate.jl")


prosumer = Prosumer(ψ₁=.99, ψ₂=1.01)
environment = Environment(ω=0.5, γ=0.5)

# sizes = (400, 10)
# pess, opt = solvepolicy(sizes, prosumer, environment; verbose=true, tol=1e-2)

T = 200
cs, xs, policy, es, p = simulate(prosumer, environment, T; verbose=true)

plotsimulation(xs, policy, es)
plotrules(pess, opt, environment, prosumer)
plotg(pess, environment, prosumer)