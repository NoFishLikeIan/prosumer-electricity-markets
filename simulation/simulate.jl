Pₛ = [1 0; 0 1]

ρₗ, ρᵤ = .99, 0.5

ε = ([ρₗ 1 - ρₗ; 1 - ρᵤ ρᵤ], [0.05, 0.1])

default_params = Dict(
    :k => 1.0,
    :β => 0.99, :βprod => 0.99,
    :M => 10_000, :N => 50,
    :ε => ε)

function simulatemarket!(model; adata=[:pos, :p, :r, :ε, :s, :b, :a],  mdata=[:X, :R], T=100, T₀=0)

    dfagent, dfmodel = run!(model, agent_step!, model_step!, T; adata, mdata)

    # Fix bug of carried over X
    modelnodes = unique(dfagent.pos)
    Nnodes = length(modelnodes)

    X = reshape(dfmodel.X[end], Nnodes, :)'[T₀:(T₀ + T), :]

    dfmodel.X = [x for x in eachrow(X)]

    return dfagent, dfmodel
end


function simulatefromsteady!(model; 
    adata=[:pos, :p, :r, :ε, :s, :b, :a],
    mdata=[:X, :R], T₀=100, T=100)

    if !isnothing(model.εpath)
        Nnodes = length(model.space.s)
        constantε = lowε * ones(T₀, Nnodes)

        model.εpath = vcat(constantε, model.εpath) # Append steady state shock
    end

    println("Bringing to steady state...")
    run!(model, agent_step!, model_step!, T₀)
    print('\n')

    println("Simulating...")
    return simulatemarket!(model; adata=adata, mdata=mdata, T=T, T₀=T₀)

end

function plotfromsteadystate(
    A, G, T; 
    parameters=default_params, 
    εpath=nothing, 
    plotpath=nothing,
    nodestoplot=Int64[]
)

    model = initializemodel(A, G, parameters; εpath=εpath)
    dfagent, dfmodel = simulatefromsteady!(model; T=T)

    if !isnothing(plotpath)

        pricesupplyplot(dfagent, model; savepath=joinpath(plotpath, "pricesupply.pdf"), nodestoplot=nodestoplot)

        plotproviderbeliefs(dfagent, model; savepath=joinpath(plotpath, "ols.pdf"))

        plotexcessdemand(dfagent, dfmodel; savepath=joinpath(plotpath, "demand.pdf"))

        plotpricevariance(dfagent, model; savepath=joinpath(plotpath, "pvar.pdf"))

        plotprofit(dfagent, model; savepath=joinpath(plotpath, "profits.pdf"))

    end

    return dfagent, dfmodel, model

end
