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

ε = (
    [0.99 0.01; 0.01 0.99],
    [-10.0, 10.0]
)

parameters = Dict(
    :c => c, :c′ => c′,
    :Ψ => [0.9, 1.1],
    :M => 100, :ε => ε,
    :N => 5, :β => 0.99
)

model = initializemodel(A, parameters)

adata = [:pos, :p, :r, :Ep, :ε, :ψ]
mdata = []

dfagent, dfmodel = run!(model, agent_step!, model_step!, 5; adata, mdata)

dfprosumer, dfprovider, dfproducer = groupby(dfagent, :agent_type)
