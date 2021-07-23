include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/stability/"

T = 100 # Simulation time
τ = 10 # Shock init
Δτ = 5 # Shock length
Tₛ = 500 # Steady state periods

lowε, highε = 2., 2.05
parameters = copy(default_params)

endowments = parameters[:ε]

parameters[:ε] = (first(endowments), (lowε, highε))
εpath = makeshock(2, 2, τ, τ + Δτ, lowε, highε)

A = [0 1; 1 0]
G = makeG(A) # 1x1 matrix with entry 0

βs = range(0.91, 0.99; length=5)

prices = zeros(length(βs), T + 1, 2)

for (idx, β) in enumerate(βs)

    println("Simulating with β = $β...")

    parametersβ = copy(parameters)
    parametersβ[:β] = parametersβ[:βprod] = β 

    model = initializemodel(A, G, parametersβ; εpath=εpath)
    dfagent, dfmodel = simulatefromsteady!(model; T=T, Tₛ=Tₛ)

    Tₗ, Tᵤ = extrema(dfagent[!, :step])
    timeaxis = Tₗ:Tᵤ

    for node in 1:2
        nodedata = getnodedata(dfagent, node)
        dfpros, dfprov, dfprod = nodedata
        prices[idx, :, node]  = dfprov.p
    end

end
println("\nDone with two!")

figβ =  plotstabilityβ(prices, βs; savepath=joinpath(plotpath, "stability.pdf"))