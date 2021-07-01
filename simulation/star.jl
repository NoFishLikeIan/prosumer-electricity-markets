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


ρₗ = 0.
ρᵤ = 1.

ε = ([ρₗ 1 - ρₗ; 1 - ρᵤ ρᵤ], [2.0, 10.0])

parameters = Dict(
    :k => 2.0,
    :β => 0.99, :βprod => 0.8,
    :M => 1_000, :N => 3,
    :ε => ε)

model = initializemodel(A, G, parameters)

if doplot

    Plots.scalefontsizes(0.6)

    adata = [:pos, :p, :r, :ε, :s, :b, :a]
    mdata = [:X, :R]

    T = 100

    dfagent, dfmodel = run!(model, agent_step!, model_step!, T; adata, mdata)

    pricesupplyplot(dfagent; savepath="plots/energy/star/pricesupply.pdf")
    plotproviderbeliefs(dfagent; savepath="plots/energy/star/ols.pdf")

    Plots.resetfontsizes()
    println("Done!")

end
