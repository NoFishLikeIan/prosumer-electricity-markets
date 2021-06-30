using Plots
using DataFrames

include("src/main.jl")

doplot = true

A = [
    0 1 1 1;
    1 0 0 0;
    1 0 0 0;
    1 0 0 0;
]

G = [
    0 1 1;
    1 0 1;
    1 1 0
]

c₁ = 100

c(s, r) = log(1 + exp(c₁ * s * r)) / c₁
S(s, r) = inv(1 + exp(-c₁ * s * r))

∂c∂s(s, r) = S(s, r) * r
∂c∂r(s, r) = S(s, r) * s


ρₗ = 0.99
ρᵤ = 0.2

ε = ([
        ρₗ 1 - ρₗ; 
        1 - ρᵤ ρᵤ
    ],
    [-10., 10.])

parameters = Dict(
    :c => (c, ∂c∂s, ∂c∂r), :k => 2.0,
    :Ψ => [0.9, 1.1],
    :β => 0.99, :βprod => 0.8,
    :M => 1_000, :N => 3,
    :ε => ε)

necessarys = parameters[:M] * 10. / parameters[:N]
s₀ = necessarys

model = initializemodel(A, G, parameters; s₀=s₀)

if doplot

    Plots.scalefontsizes(0.6)

    adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s, :b, :a]
    mdata = [:X, :R]

    T = 100

    dfagent, dfmodel = run!(
        model, agent_step!, model_step!, T; 
        adata, mdata)

    figrp = pricesupplyplot(dfagent; savepath="plots/energy/pricesupply.pdf")

    plotproducerbeliefs(dfagent; savepath="plots/energy/optimistics.pdf")

    plotproviderbeliefs(dfagent; savepath="plots/energy/ols.pdf")

    Plots.resetfontsizes()
    println("Done!")

end
