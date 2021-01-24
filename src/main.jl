using Parameters, QuantEcon
using Base.Threads
using Interpolations, Roots

using Plots, Logging, Printf

include("utils.jl")
include("plotting.jl")
include("markets/local.jl")
include("algos/endgrid.jl")

prosumer, environment = Prosumer(), Environment()

sizes = (400, 10)
g = solvepolicy(sizes, prosumer, environment; verbose=true, ρ0=1.)

plotg(g, environment)
