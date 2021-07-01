include("src/main.jl")
include("simulate.jl")

plotpath = "../plots/energy/line/"

doplot = true

A, G = makeline(15)

println("Simulating stable...")

ρₗ, ρᵤ = 0., 1.

ε = ([ρₗ 1 - ρₗ; 1 - ρᵤ ρᵤ], [2.0, 10.0])

parameters = Dict(
    :k => 2.0,
    :β => 0.99, :βprod => 0.8,
    :M => 1_000, :N => 3,
    :ε => ε)

model = initializemodel(A, G, parameters)
dfagent, dfmodel = simulatemarket(model; T=1_000)

Plots.resetfontsizes(); Plots.scalefontsizes(0.8)
default(size=(1200, 800), margin=5Plots.mm)

if doplot

    dfagentstable = dfagent[dfagent.step .> 100, :]
    dfmodelstable = dfmodel[dfmodel.step .> 100, :]
    pricesupplyplot(dfagentstable; savepath=joinpath(plotpath, "pricesupply.pdf"))

    plotproviderbeliefs(dfagentstable; savepath=joinpath(plotpath, "ols.pdf"))

    plotexcessdemand(dfagentstable, dfmodelstable; savepath=joinpath(plotpath, "demand.pdf"))

    
    plotpricevariance(dfagentstable, model; savepath=joinpath(plotpath, "pvar.pdf"))

end

println("Simulating unstable...")

ρₗ, ρᵤ = 0.99, 0.99

ε = ([ρₗ 1 - ρₗ; 1 - ρᵤ ρᵤ], [2.0, 10.0])
parameters[:ε] = ε

model = initializemodel(A, G, parameters)
dfagent, dfmodel = simulatemarket(model; T=1_000)

if doplot

    dfagentunstable = dfagent[dfagent.step .> 100, :]
    dfmodelunstable = dfmodel[dfmodel.step .> 100, :]

    pricesupplyplot(dfagentunstable; savepath=joinpath(plotpath, "unstable_pricesupply.pdf"))

    plotproviderbeliefs(dfagentunstable; savepath=joinpath(plotpath, "unstable_ols.pdf"))

    plotexcessdemand(dfagentunstable, dfmodelunstable; savepath=joinpath(plotpath, "unstable_demand.pdf"))

    
    plotpricevariance(dfagentunstable, model; savepath=joinpath(plotpath, "unstable_pvar.pdf"))


end

println("...done!")

Plots.resetfontsizes()