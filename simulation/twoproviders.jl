include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/two"

lowε, highε = 0.5, 1.2
parameters = copy(default_params)

endowments = parameters[:ε]

parameters[:ε] = (first(endowments), (lowε, highε))

makeshock(from, to) = makeshock(from, to, lowε, highε)
function makeshock(from, to, ε, εₛ)
    εpath = ε * ones(T + 1, 2)
    εpath[from:to, 2] .=  εₛ

    return εpath
end

A = [0 1; 1 0]
G = makeG(A) # 1x1 matrix with entry 0

T = 150 # Simulation time
τ = 100 # Shock init
Δτ = 10 # Shock length

εpath = makeshock(τ, τ + Δτ)

model = initializemodel(A, G, parameters; εpath=εpath)
dfagent, dfmodel = simulatefromsteady!(model; T=T, Tₛ=150)

excessdemand = plotexcessdemand(dfagent, dfmodel, savepath=joinpath(plotpath, "demand.pdf"))

pricesupply = pricesupplyplot(dfagent, model; savepath=joinpath(plotpath, "pricesupply.pdf"))

ols = plotproviderbeliefs(dfagent, model; savepath=joinpath(plotpath, "ols.pdf"))

println("\nDone with two!")