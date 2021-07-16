Pₛ = [1 0; 0 1]

ρₗ, ρᵤ = .99, 0.5

ε = ([ρₗ 1 - ρₗ; 1 - ρᵤ ρᵤ], [1., 2.])

default_params = Dict(
    :k => 1.0,
    :β => 0.9, :βprod => 0.9,
    :M => 8_000, :N => 50,
    :ε => ε)

adata = [:pos, :p, :r, :ε, :s, :γ, :η, :α]
mdata = [:X, :R]

function simulatemarket!(model; adata=adata, mdata=mdata, T=100, Tₛ=1)

    dfagent, dfmodel = run!(model, agent_step!, model_step!, T; adata, mdata)

    # Fix bug of carried over X
    modelnodes = unique(dfagent.pos)
    Nnodes = length(modelnodes)

    X = reshape(dfmodel.X[end], Nnodes, :)'[Tₛ:(Tₛ + T), :]

    dfmodel.X = [x for x in eachrow(X)]

    return dfagent, dfmodel
end


function simulatefromsteady!(model; adata=adata, mdata=mdata, T=100, Tₛ=50)

    if !isnothing(model.εpath)
        Nnodes = length(model.space.s)
        constantε = lowε * ones(Tₛ, Nnodes)

        model.εpath = vcat(constantε, model.εpath) # Append steady state shock
    end

    println("Bringing to steady state...")
    run!(model, agent_step!, model_step!, Tₛ)
    print('\n')

    println("Simulating...")
    return simulatemarket!(model; adata=adata, mdata=mdata, T=T, Tₛ=Tₛ)

end

function plotallsimulation(
    A, G, T;
    parameters=default_params, 
    εpath=nothing, 
    plotpath=nothing,
    fromsteady=false,
    nodestoplot=Int64[]
)

    simfunction! = fromsteady ? simulatefromsteady! : simulatemarket!

    model = initializemodel(A, G, parameters; εpath=εpath)
    dfagent, dfmodel = simfunction!(model; T=T)

    if !isnothing(plotpath)

        pricesupplyplot(dfagent, model; savepath=joinpath(plotpath, "pricesupply.pdf"), nodestoplot=nodestoplot)

        plotproviderbeliefs(dfagent, model; savepath=joinpath(plotpath, "ols.pdf"), nodestoplot=nodestoplot)

        plotexcessdemand(dfagent, dfmodel; savepath=joinpath(plotpath, "demand.pdf"))

        plotpricevariance(dfagent, model; savepath=joinpath(plotpath, "pvar.pdf"))

        plotprofit(dfagent, model; savepath=joinpath(plotpath, "profits.pdf"))

    end

    return dfagent, dfmodel, model

end
