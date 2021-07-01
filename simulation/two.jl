using Plots
using DataFrames

include("src/main.jl")

plotpath = "../plots/energy/two"

A = [
    0 1;
    1 0
]

G = hcat(0) # Matrix with one entry

ρₗ = 0.99
ρᵤ = 0.2

ε = ([
        ρₗ 1 - ρₗ; 
        1 - ρᵤ ρᵤ
    ],
    [-10., 10.])

parameters = Dict(
    :k => 2.0,
    :Ψ => [0.9, 1.1],
    :β => 0.99, :βprod => 0.8,
    :M => 1_000, :N => 3,
    :ε => ε)

model = initializemodel(A, G, parameters)


adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s, :b, :a]
mdata = [:X, :R]

T = 5

dfagent, dfmodel = run!(model, agent_step!, model_step!, T;adata, mdata)


pricesupplyplot(dfagent; savepath=joinpath(plotpath, "pricesupply.pdf"))

plotproducerbeliefs(dfagent; savepath=joinpath(plotpath, "optimistics.pdf"))

plotproviderbeliefs(dfagent; savepath=joinpath(plotpath, "ols.pdf"))