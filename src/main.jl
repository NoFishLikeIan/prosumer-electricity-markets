using Parameters, QuantEcon
using Base.Threads
using Interpolations, Roots

using Plots, Logging, Printf

include("utils.jl")
include("plotting.jl")
include("markets/local.jl")
include("algos/endgrid.jl")


prosumer = Prosumer(ψ₁=0.95, ψ₂=1.05)
environment = Environment()

sizes = (400, 10)
pess, opt = solvepolicy(sizes, prosumer, environment; verbose=true, tol=1e-2)

# plotg(g, environment)

plotrules(pess, opt, environment, prosumer)