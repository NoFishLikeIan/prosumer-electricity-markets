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

c₁ = 1.0

c(s, r) = log(1 + exp(c₁ * s * r))
∇c(s, r) = c₁ * inv(1 + exp(-c₁ * s * r))

∂c∂s(s, r) = ∇c(s, r) * r
∂c∂r(s, r) = ∇c(s, r) * s

ρₗ = ρᵤ = 0.9

ε = ([
        ρₗ 1 - ρₗ; 
        1 - ρᵤ ρᵤ
    ],
    [0.0, 10.0])

parameters = Dict(
    :c => (c, ∂c∂s, ∂c∂r),
    :Ψ => [0.9, 1.1],
    :M => 500, :ε => ε,
    :N => 3, :β => 0.99,
    :βprod => 0.5)

necessarys = parameters[:M] * 10. / parameters[:N]
s₀ = necessarys * 0.9

model = initializemodel(
    A, parameters;
    s₀=s₀, b₀=0.
)

if doplot

    adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s, :b, :a]
    mdata = [:X, :R]

    T = 100

    dfagent, dfmodel = run!(
        model, agent_step!, model_step!, T; 
        adata, mdata)

    Plots.scalefontsizes(0.6)

    figrp = pricesupplyplot(dfagent; savepath="plots/energy/pricesupply.pdf")

    plotproducerbeliefs(dfagent; savepath="plots/energy/optimistics.pdf")

    plotproviderbeliefs(dfagent; savepath="plots/energy/ols.pdf")

    println("Done!")

    Plots.resetfontsizes()

end
