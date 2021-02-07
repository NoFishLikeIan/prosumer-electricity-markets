using Parameters, QuantEcon
using Base.Threads
using Interpolations, Roots
using FiniteDifferences
using Random, Distributions

using Plots, Logging, Printf

Random.seed!(11148705)
Plots.scalefontsizes(.6)

include("utils.jl")
include("markets/local.jl")
include("markets/oneglobal.jl")

include("algos/endgrid.jl")

include("simulation/simutils.jl")
include("simulation/exdecision.jl")
include("simulation/onedecision.jl")
include("simulation/simulation.jl")

include("plotting/local.jl")
include("plotting/global.jl")

do_plot = false

prosumer = Prosumer(ψ₁=.99, ψ₂=1.01)
environment = Environment(ω=0.5, γ=0.5)


sizes = (600, 100)
pess, opt = solvepolicy(sizes, prosumer, environment; verbose=true, tol=1e-2)

T = 100
ms, xs, policy, es, p = simulate(
    pess, opt, prosumer, environment, T; 
    verbose=true, exog=false)

if do_plot

    plotsimulation(xs, policy, es)

    plotrules(pess, opt, environment, prosumer)
    plotg(pess, environment, prosumer)
    plotdemand(pess, environment)

end

Plots.resetfontsizes()
