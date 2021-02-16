using Parameters, QuantEcon
using Base.Threads
using Interpolations, Roots
using FiniteDifferences
using Random, Distributions

using Plots, Logging, Printf
using StatsPlots, DataFrames

Random.seed!(11148705)
Plots.scalefontsizes(.6)

include("utils.jl")
include("markets/local.jl")
include("markets/oneglobal.jl")

include("algos/endgrid.jl")

include("simulation/simutils.jl")
include("simulation/decision.jl")
include("simulation/simulation.jl")

include("plotting/local.jl")
include("plotting/global.jl")

prosumer = Prosumer(ψ₁=.95, ψ₂=1.01)
environment = Environment(ω=0.5, γ=0.5)


sizes = (600, 100)
pess, opt = solvepolicy(sizes, prosumer, environment; verbose=true, tol=1e-2)

policy_plots = true

if policy_plots
    plotrules(pess, opt, environment, prosumer)
    plotg(pess, environment, prosumer)
    plotdemand(pess, environment)
    
    plotsimplesolution(pess, opt, environment; m=10.)
end

N, T = 20, 100
ms, xs, policy, es, p = simulate(
    pess, opt, prosumer, environment, 
    T, N; 
    verbose=true, exog=true)

simulation_plots = false

if simulation_plots
    plotsimulation(xs, es; policy=policy)
    plottypes(policy, es)
    plotpricesdemand(xs, es, p)
end


Plots.resetfontsizes()