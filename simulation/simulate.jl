Pₛ = [1 0; 0 1]

ρₗ, ρᵤ = .99, 0.5

ε = ([ρₗ 1 - ρₗ; 1 - ρᵤ ρᵤ], [2.0, 10.0])

default_params = Dict(
    :k => 2.0,
    :β => 0.9, :βprod => 0.9,
    :M => 1_000, :N => 3,
    :ε => ε)

function simulatemarket!(model; adata=[:pos, :p, :r, :ε, :s, :b, :a],  mdata=[:X, :R], T=100)

    dfagent, dfmodel = run!(model, agent_step!, model_step!, T; adata, mdata)

    # Fix bug of carried over X
    modelnodes = unique(dfagent.pos)
    Nnodes = length(modelnodes)

    X = reshape(dfmodel.X[end], Nnodes, :)'

    dfmodel.X = [x for x in eachrow(X)]

    return dfagent, dfmodel
end


function simulatefromsteady!(model; 
    adata=[:pos, :p, :r, :ε, :s, :b, :a],
    mdata=[:X, :R], T₀=1_000, T=100)

    ε = model.ε
    εₛ = (Pₛ, ε[2])

    println("Bringing to steady state...")
    model.ε = εₛ # Set to steady state Markov chain
    run!(model, agent_step!, model_step!, T₀)

    println("Simulating...")
    model.ε = ε # Set back 
    dfagent, dfmodel = run!(model, agent_step!, model_step!, T; adata, mdata)

    # Fix bug of carried over X
    modelnodes = unique(dfagent.pos)
    Nnodes = length(modelnodes)

    X = reshape(dfmodel.X[end], Nnodes, :)'[(T₀ + 1):end, :]

    dfmodel.X = [x for x in eachrow(X)]

    return dfagent, dfmodel

end

function plotfromsteadystate(A, G, T; parameters=default_params, εpath=nothing, plotpath=nothing)

    model = initializemodel(A, G, parameters; εpath=εpath)
    dfagent, dfmodel = simulatemarket!(model; T=T)

    if !isnothing(plotpath)

        pricesupplyplot(dfagent, model; savepath=joinpath(plotpath, "pricesupply.pdf"))

        plotproviderbeliefs(dfagent, model; savepath=joinpath(plotpath, "ols.pdf"))

        plotexcessdemand(dfagent, dfmodel; savepath=joinpath(plotpath, "demand.pdf"))

        plotpricevariance(dfagent, model; savepath=joinpath(plotpath, "pvar.pdf"))

        plotprofit(dfagent, model; savepath=joinpath(plotpath, "profits.pdf"))

    end

    return dfagent, dfmodel, model

end