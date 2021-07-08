"""
Plot the supply and the price in all markets
"""
function pricesupplyplot(dfagent, model; savepath=nothing)

    pmax = maximum(filter(!ismissing, dfagent.p))

    jointfigure = plotnodes(
        dfagent,
        (timeaxis, nodedata) -> begin
        dfpros, dfprov, dfprod = nodedata
        node = dfpros[1, :pos]
            
        εperiods = highdemandperiods(dfpros, model)
        pricet = dfprov[!, :p]

        supply = combine(
            groupby(dfprod, [:step]), :s => sum
        )[!, :s_sum]

        fig = plot(
            timeaxis, pricet, 
            title="Node $node", label="price", color=:blue, 
            ylims=(0, pmax), ylabel="p", legend=:topleft)
                    
        for (startp, endp) in εperiods
            vspan!(fig, [startp, endp], color=:red, alpha=0.3, label=nothing)
        end

        fig = bar!(
            twinx(fig), timeaxis, supply, ylabel="supply", alpha=0.2,
            ylims=(0, Inf), label="s", color=:green, legend=:topright)
            
        return fig

    end)

    if !isnothing(savepath)
        savefig(jointfigure, savepath)
    else
        return jointfigure
    end

    end


function plotproviderbeliefs(dfagent, model; savepath=nothing)
    jointfigure = plotnodes(
        dfagent,
        (time, nodedata) -> begin
        dfpros, dfprov, dfprod = nodedata
        node = dfpros[1, :pos]
            
        εperiods = highdemandperiods(dfpros, model)

        as, bs = eachcol(dfprov[!, [:a, :b]])

        fig = plot(
            time, bs, 
            title="Node $node", label="slope", color=:blue, legend=:topleft)
            
        vspan!(fig, εperiods, color=:red, alpha=0.3, label=nothing)

        plot!(twinx(fig), time, as, label="intercept", color=:red, legend=:bottomright)
            
        return fig

    end)

        if !isnothing(savepath)
        savefig(jointfigure, savepath)
    else
        return jointfigure
    end
end

function plotexcessdemand(dfagent, dfmodel; savepath=nothing)
    modelnodes = unique(dfagent.pos)
    Tₗ, Tᵤ = extrema(dfmodel.step)
    time =  Tₗ:Tᵤ
    X = hcat(dfmodel.X...)'

    figure = plot(title="Excess demand", xlabel="time", ylabel="X")

    for (i, node) in enumerate(modelnodes)
        plot!(time, X[:, i], label="X$node (t)")
    end
    
    if !isnothing(savepath)
        savefig(figure, savepath)
    else
        return figure
    end
end

computenodesize(N) = 1 / (3 * sqrt(N))

function plotpricevariance(dfagent, model; savepath=nothing)
    g = model.space.graph   

    markets = vertices(g)
    N = length(markets)

    pricevariance = Float64[]

    for node in markets
    _, dfprov, _ = getnodedata(dfagent, node)
        σₚ = std(dfprov.p)

        push!(pricevariance, σₚ)
    end
    
    nodelabel = [
        "σₚ($i) = $( @sprintf "%.0f" σ )" for (i, σ) in enumerate(pricevariance)]
        
    alphas = rescaleto(pricevariance, 0.5, 1.0)

    nodefillc = map(makecolor(:blue), alphas)

    context = gplot(
        g, nodefillc=nodefillc, 
        nodelabel=nodelabel,
        NODESIZE=computenodesize(N),
        layout=circular_layout)

    if !isnothing(savepath) draw(PDF(savepath, 32cm, 32cm), context) end

    return context
end


function plotprofit(dfagent, model; savepath=nothing)
    g = model.space.graph

    nodelabel = unique(dfagent.pos)
    
    profit = sum(reshape(model.profit, length(nodelabel), :), dims=2) |> vec

    alphas = rescaleto(profit, 0.1, 1.0)

    nodefillc = map(makecolor(:blue), alphas)

       
    nodelabel = [
        "π($i) = $(@sprintf "%.2E" prof)" 
        for (i, prof) in enumerate(profit)]

    context = gplot(
        g, nodefillc=nodefillc, 
        nodelabel=nodelabel, 
        NODESIZE=computenodesize(N),
        layout=circular_layout)
    
    if !isnothing(savepath) draw(PDF(savepath, 32cm, 32cm), context) end


end

function compareblackout(dfmodelstar, dfmodelline;  savepath=nothing)
    Xstar = abs.(sum(hcat(dfmodelstar.X...)', dims=2))
    Xline = abs.(sum(hcat(dfmodelline.X...)', dims=2))

    t = dfmodelstar.step
    ΔX = Xstar - Xline

    figure = bar(t, ΔX, label="Star - Line")
        
    if !isnothing(savepath)
        savefig(figure, savepath)
    else
        return figure
    end
end