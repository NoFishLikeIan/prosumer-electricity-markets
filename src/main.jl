using Parameters, QuantEcon
using Base.Threads
using Interpolations, Roots
using FiniteDifferences
using Random, Distributions

using Plots, Logging, Printf
using LightGraphs, GraphPlot
using StatsPlots, DataFrames

Random.seed!(11148705)

include("utils.jl")

include("markets/local.jl")
include("algos/endgrid.jl")

include("markets/global.jl")

include("simulation/simutils.jl")
include("simulation/decision.jl")
include("simulation/simulation.jl")

include("plotting/local.jl")
include("plotting/global.jl")


simulation_plots = false

if simulation_plots

    Plots.scalefontsizes(.6)

    prosumer = Prosumer(ψ₁=.95, ψ₂=1.01)
    environment = Environment(ω=0.5, γ=0.5)

    sizes = (600, 100)
    pess, opt = solvepolicy(sizes, prosumer, environment; verbose=true, tol=1e-2)


    N, T = 20, 100
    ms, xs, policy, es, p = simulate(
    pess, opt, prosumer, environment, 
    T, N; 
    verbose=true, exog=true)

    plotsimulation(xs, es; policy=policy)
    plottypes(policy, es)
    plotpricesdemand(xs, es, p)

    Plots.resetfontsizes()
end
