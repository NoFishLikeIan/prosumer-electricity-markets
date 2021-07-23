include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/two"

T = 200 # Simulation time
τ = 100 # Shock init
Δτ = 5 # Shock length
Tₛ = 500 # Steady state periods

lowε, highε = 2., 8.
parameters = copy(default_params)

endowments = parameters[:ε]

parameters[:ε] = (first(endowments), (lowε, highε))

A = [0 1; 1 0]
G = makeG(A) # 1x1 matrix with entry 0

εpath = makeshock(2, 2, τ, τ + Δτ, lowε, highε)

model = initializemodel(A, G, parameters; εpath=εpath)
dfagent, dfmodel = simulatefromsteady!(model; T=T, Tₛ=Tₛ)

excessdemand = plotexcessdemand(dfagent, dfmodel, savepath=joinpath(plotpath, "demand.pdf"))

pricesupply = pricesupplyplot(dfagent, model; savepath=joinpath(plotpath, "pricesupply.pdf"))

ols = plotproviderbeliefs(dfagent, model; savepath=joinpath(plotpath, "ols.pdf"))

println("\nDone with two!")