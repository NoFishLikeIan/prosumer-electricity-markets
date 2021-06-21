using Plots
using DataFrames

include("src/main.jl")

doplot = false

A = [
    0 1 1 1;
    1 0 0 0;
    1 0 0 0;
    1 0 0 0;
]

c₁ = 1.0

c(s, r) = log(1 + exp(c₁ * s * r))
∇c(s, r) = c₁ * inv(1 + exp(-c₁ * s * r))

∂c∂s(s, r) = ∇c(s, r) * r
∂c∂r(s, r) = ∇c(s, r) * s

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
    :c => (c, ∂c∂s, ∂c∂r),
    :Ψ => [0.9, 1.1],
    :M => 500, :ε => ε,
    :N => 15, :β => 0.99,
    :βprod => 0.5
)

s₀ = 20.0

model = initializemodel(
    A, parameters;
    s₀=s₀, b₀=0.
)

adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s]
mdata = []

T = 5

dfagent, dfmodel = run!(
    model, agent_step!, model_step!, T; 
    adata, mdata)

provider = model[2]
producer = model[3]

if doplot

    Plots.scalefontsizes(0.6)

    figrp = priceplot(dfagent; savepath="plots/energy/price.pdf")
    figsp = supplyplot(dfagent; savepath="plots/energy/supply.pdf")
    println("Done!")

    Plots.resetfontsizes()

end