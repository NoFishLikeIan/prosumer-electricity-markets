# Defaults
theme(:vibrant)
default(size=(297 * 3, 210 * 3), dpi=300, margin=margin = 5Plots.mm)
Plots.resetfontsizes()


"""
Plot the supply and the price in all markets
"""
function pricesupplyplot(dfagent, model; savepath=nothing, nodestoplot=Int64[])

    pmin, pmax = extrema(filter(!ismissing, dfagent.p))

    ylower = min(pmin, 0.)

    singleplot = (timeaxis, nodedata) -> begin
        dfpros, dfprov, dfprod = nodedata
        node = dfpros[1, :pos]
            
        εperiods = highdemandperiods(dfpros, model)   

        c₁, c₂, c₃ = Plots.palette(:tab10)

        pricet = dfprov[!, :p]

        supply = combine(
            groupby(dfprod, [:step]), :s => sum
        )[!, :s_sum]

        fig = plot(
            timeaxis, pricet, 
            title="Node $node", label="price", 
            color=c₁, ylims=(ylower, pmax),
            legend=:topright)
                    
        for (startp, endp) in εperiods

            span = [timeaxis[startp], timeaxis[endp]]

            vspan!(fig, span, color=c₂, alpha=0.2, label=nothing)
        end

        fig = bar!(
            twinx(fig), timeaxis, supply, alpha=0.2,
            ylims=(0, Inf), 
            label="supply", color=c₃, 
            legend=:topleft)
            
        return fig
    end

    jointfigure = plotnodes(dfagent, singleplot; nodestoplot=nodestoplot)

    if !isnothing(savepath) savefig(jointfigure, savepath) end
    
    return jointfigure

end


function plotproviderbeliefs(dfagent, model; savepath=nothing, nodestoplot=Int64[])
    jointfigure = plotnodes(
        dfagent,
        (timeaxis, nodedata) -> begin
        dfpros, dfprov, dfprod = nodedata
        node = dfpros[1, :pos]

        cs = Plots.palette(:tab10)

        αlabel = latexstring("\$ \\alpha_t \$")
        ηlabel = latexstring("\$ \\eta_t \$")
        γlabel = latexstring("\$ \\gamma_t \$")
        
        εperiods = highdemandperiods(dfpros, model)
            
        αs, γs, ηs = eachcol(dfprov[!, [:α, :γ, :η]])

        figure = plot(timeaxis, ηs, label=ηlabel, c=cs[1], title="Node $node")

        plot!(figure, timeaxis, γs, label=γlabel, c=cs[2])

        fig = plot!(
            twinx(figure),
            timeaxis, αs, 
            c=cs[3], label=αlabel, legend=:bottomright)
            
        for (startp, endp) in εperiods
            vspan!(fig, [startp, endp], color=:red, alpha=0.3, label=nothing)
        end
            
        return fig

    end; nodestoplot=nodestoplot)

        if !isnothing(savepath)
        savefig(jointfigure, savepath)
    end
    
    return jointfigure
end

function plotexcessdemand(dfagent, dfmodel; savepath=nothing)
    modelnodes = unique(dfagent.pos)
    Tₗ, Tᵤ = extrema(dfmodel.step)
    time =  Tₗ:Tᵤ
    X = hcat(dfmodel.X...)'

    ∑X = positive.(sum(X, dims=2))
    
    figure = plot(title="Excess demand", xlabel=latexstring("\$ t \$"))
    
    for (i, node) in enumerate(modelnodes)
        plot!(figure, time, X[:, i], label=latexstring("\$ X_{$node, t} \$"))
    end
    
    bar!(figure, time, ∑X, label=latexstring("\$ \\sum_i X_{i, t} \$"), legend=:bottomright, alpha=.5, linecolor=:match)

    if !isnothing(savepath)
        savefig(figure, savepath)
    end
    return figure
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

function compareblackout(excdemand, ns; savepath=nothing)
	blackoutlabel = latexstring("\$\\{t: t \\geq \\tau, \\sum_{i} X_{i, t} > 0 \\} \$")
    coherencelabel = latexstring("\$ n \$")
    
    figure = plot(xlabel=coherencelabel, ylabel=blackoutlabel, yticks=0:1:10,)
        
    for (i, results) in enumerate(excdemand)

        graphname, data = results
        
        col = Plots.palette(:tab10)[i]

        presentrows = any((!isnan).(data), dims=2) |> vec

        _, blk = eachcol(data[presentrows, :])

        cumulativeblackout = floor.(Int64, blk)

        scatter!(
            figure, ns, cumulativeblackout; markersize=2,
            c=col, label=graphname)
        
        plot!(figure, ns, cumulativeblackout; c=col, label=nothing)
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
        
        scatter!(figure, ns[notnan], ρs[notnan]; markersize=2, c=col, label=graphname, legend = :topleft)

        plot!(figure, ns[notnan], ρs[notnan]; alpha=0.5, c=col, label=nothing)
        
    end
    
        
    if !isnothing(savepath)
        savefig(figure, savepath)
    end
    return figure
end