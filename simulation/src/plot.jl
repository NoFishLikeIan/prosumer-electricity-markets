# Defaults
theme(:vibrant)
default(size=(800, 600), dpi=300, margin=margin = 5Plots.mm)
Plots.resetfontsizes()


"""
Plot the supply and the price in all markets
"""
function pricesupplyplot(dfagent, model; savepath=nothing, nodestoplot=Int64[])

    pmax = maximum(filter(!ismissing, dfagent.p))

    singleplot = (timeaxis, nodedata) -> begin
        dfpros, dfprov, dfprod = nodedata
        node = dfpros[1, :pos]
            
        εperiods = highdemandperiods(dfpros, model)
        pricet = dfprov[!, :p]

        supply = combine(
            groupby(dfprod, [:step]), :s => sum
        )[!, :s_sum]

        fig = plot(
            timeaxis, pricet, 
            title="Node $node", label="price", 
            color=:blue, ylims=(0, pmax),
            legend=:topright)
                    
        for (startp, endp) in εperiods
            vspan!(fig, [startp, endp], color=:red, alpha=0.3, label=nothing)
        end

        fig = bar!(
            twinx(fig), timeaxis, supply, alpha=0.2,
            ylims=(0, Inf), 
            label="supply", color=:green, 
            legend=:right)
            
        return fig
    end

    jointfigure = plotnodes(dfagent, singleplot; nodestoplot=nodestoplot)

    if !isnothing(savepath) savefig(jointfigure, savepath) end
    
    return jointfigure

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
            title="Node $node", label="slope", legend=:topleft)
            
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

    ∑X = positive.(sum(X, dims=2))

    figure = plot(title="Excess demand", xlabel="time", ylabel="X")

    for (i, node) in enumerate(modelnodes)
        plot!(figure, time, X[:, i], label="X$node (t)")
    end
    
    bar!(figure, time, ∑X, label="∑X > 0", legend=:bottomright, alpha=.5, linecolor=:match)

    if !isnothing(savepath)
        savefig(figure, savepath)
    else
        return figure
    end
end

computenodesize(N) = 1 / (3 * sqrt(N))

function plotpricevariance(dfagent, model; savepath=nothing)
    g = model.space.graph  
    N = length(g)
    
    pricevariance = getpricevariance(dfagent, model)
        
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
    N = length(nodelabel)
    
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

    return context

end

function compareblackout(excdemand; savepath=nothing)
	blackoutlabel = latexstring("\$ \\frac{\\sum_{t \\geq \\tau, i} X_{i, t}}{T - \\tau} \$")
    coherencelabel = latexstring("\$ \\rho\\left( \\mathcal{A} \\right)\$")
    
    figure = plot(xlabel=coherencelabel, ylabel=blackoutlabel)
        
    for (i, results) in enumerate(excdemand)

        graphname, data = results
        
        col = Plots.palette(:tab10)[i]

        presentrows = any((!isnan).(data), dims=2) |> vec

        ρs, cumulativeblackout, σ = eachcol(data[presentrows, :])

        srt = sortperm(ρs)

        scatter!(
            figure, ρs[srt], cumulativeblackout[srt]; markersize=2,
            c=col, label=graphname)
        
        plot!(figure, ρs[srt], cumulativeblackout[srt]; c=col, label=nothing)
    end
        
    if !isnothing(savepath)
        savefig(figure, savepath)
    end
    return figure
end

function plotcoherences(excdemand, ns; savepath=nothing)

    figure = plot(xlabel=latexstring("\$ n \$"), ylabel=latexstring("\$ \\rho\$"))
        
    for (i, results) in enumerate(excdemand)

        graphname, data = results
        
        col = Plots.palette(:tab10)[i]
        
        ρs = data[:, 1]

        notnan = (!isnan).(ρs)
        
        scatter!(figure, ns[notnan], ρs[notnan]; markersize=2, c=col, label=graphname)

        plot!(figure, ns[notnan], ρs[notnan]; alpha=0.5, c=col, label=nothing)
        
    end
    
        
    if !isnothing(savepath)
        savefig(figure, savepath)
    end
    return figure
end