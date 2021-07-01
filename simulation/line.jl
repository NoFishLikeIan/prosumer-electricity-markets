using Plots
using DataFrames

include("src/main.jl")

plotpath = "plots/energy/line"

function makeline(n)
    A = zeros(Int64, n, n)
    A[diagind(A, 1)] .= 1
    A[diagind(A, -1)] .= 1

    G = zeros(Int64, n - 1, n - 1)
    G[diagind(G, 1)] .= 1
    G[diagind(G, -1)] .= -1


    return A, G
end

ρₗ = 0.99
ρᵤ = 0.99

ε = ([
        ρₗ 1 - ρₗ; 
        1 - ρᵤ ρᵤ
    ],
    [5., 10.])

parameters = Dict(
    :k => 2.0,
    :Ψ => [0.9, 0.9],
    :β => 0.99, :βprod => 0.8,
    :M => 1_000, :N => 3,
    :ε => ε)


A, G = makeline(100)
model = initializemodel(A, G, parameters)


adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s, :b, :a]
mdata = [:X, :R]

T = 100

dfagent, dfmodel = run!(model, agent_step!, model_step!, T;adata, mdata)


pricesupplyplot(dfagent; savepath=joinpath(plotpath, "pricesupply.pdf"))

plotproducerbeliefs(dfagent; savepath=joinpath(plotpath, "optimistics.pdf"))

plotproviderbeliefs(dfagent; savepath=joinpath(plotpath, "ols.pdf"))