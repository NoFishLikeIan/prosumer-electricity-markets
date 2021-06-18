using Plots
using DataFrames

include("src/main.jl")

A = [
    0 1 1 1;
    1 0 0 0;
    1 0 0 0;
    1 0 0 0;
]

c(x) = x^3
c′(x) = 2x^2

ρ = 0.9

ε = (
    [ρ 1 - ρ; 1 - ρ ρ],
    [10.0, 100.0]
)

parameters = Dict(
    :c => c, :c′ => c′,
    :Ψ => [0.9, 1.1],
    :M => 1000, :ε => ε,
    :N => 3, :β => 0.99
)

model = initializemodel(A, parameters)

adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s]
mdata = []

T = 5

dfagent, dfmodel = run!(model, agent_step!, model_step!, T; adata, mdata)

dfprosumer, dfprovider, dfproducer = groupby(dfagent, :agent_type)

figrp = priceplot(dfagent; savepath="plots/energy/price.svg")
figsp = supplyplot(dfagent; savepath="plots/energy/supply.svg")
println("Done!")
