using Plots
using DataFrames

include("src/main.jl")

A = [
    0 1 1 1;
    1 0 0 0;
    1 0 0 0;
    1 0 0 0;
]

c(x) = x^2
c′(x) = 2x

ρₗ = 0.9
ρᵤ = 0.8

ε = (
    [
        ρₗ 1 - ρₗ; 
        1 - ρᵤ ρᵤ
    ],
    [0.0, 10.0]
)

parameters = Dict(
    :c => c, :c′ => c′,
    :Ψ => [0.9, 1.1],
    :M => 500, :ε => ε,
    :N => 15, :β => 0.99
)

model = initializemodel(
    A, parameters;
    s₀=5.0, b₀=0.
)

adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s]
mdata = []

T = 500

dfagent, dfmodel = run!(
    model, agent_step!, model_step!, T; 
    adata, mdata)

dfprosumer, dfprovider, dfproducer = groupby(dfagent, :agent_type)

Plots.scalefontsizes(0.6)

figrp = priceplot(dfagent; savepath="plots/energy/price.pdf")
figsp = supplyplot(dfagent; savepath="plots/energy/supply.pdf")
println("Done!")

Plots.resetfontsizes()
