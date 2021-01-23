using Plots
using Parameters, QuantEcon
using Base.Threads

include("markets/optsetup.jl")
include("markets/local.jl")

results = solve(prosumer_ddp, PFI)
