# Defaults
theme(:vibrant)
default(size=(297 * 3, 210 * 3), dpi=300, margin=margin = 5Plots.mm)
Plots.resetfontsizes()


"""
Plot the supply and the price in all markets
"""
function pricesupplyplot(dfagent, model; savepath=nothing, nodestoplot=Int64[])

    pmin, pmax = extrema(filter(!ismissing, dfagent.p))

    bound = min(abs(pmin), abs(pmax))

    singleplot = (timeaxis, nodedata) -> begin
        dfpros, dfprov, dfprod = nodedata
        node = dfpros[1, :pos]
            
        εperiods = highdemandperiods(dfpros, model)   

        c₁ = makecolor(:blue)()
        c₂ = makecolor(:cobalto)()
        c₃ = makecolor(:siena)()

        pricet = dfprov[!, :p]

        supply = combine(
            groupby(dfprod, [:step]), :s => sum
        )[!, :s_sum]

        fig = plot(title="Node $node", xlabel=latexstring("\$ t \$"))
        
        bar!(
            fig, timeaxis, supply,
            ylims=(0, Inf), 
            linewidth=0, linecolor=c₂,
            label=latexstring("\$ S_{$node, t} \\ (left) \$"), color=c₂, alpha=0.57,
            legend=(0.1, 0.8))

        for (startp, endp) in εperiods

            span = [timeaxis[startp], timeaxis[endp]]

            vspan!(fig, span, color=c₃, label=nothing)
        end

        plot!(
            twinx(fig),
            timeaxis, pricet, 
            color=c₁, ylims=(-bound, bound),
            label=latexstring("\$ p_{$node, t} \\ (right) \$"),
            legend=(0.1, 0.9))
            
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
            span = [timeaxis[startp], timeaxis[endp]]
            vspan!(fig, span, color=:red, alpha=0.3, label=nothing)
        end
            
        return fig

    end; nodestoplot=nodestoplot)

        if !isnothing(savepath)
        savefig(jointfigure, savepath)
    end
    
    return jointfigure
end

function plotexcessdemand(dfagent, dfmodel; savepath=nothing, othernodes=[])   
    
    cᵪ = makecolor(:siena)()
    cₚ = makecolor(:cobalto)()
    cₐ = makecolor(:orange)()
    
    εₕ = filter(!ismissing, dfagent.ε) |> maximum
    
    
    othernodes = isempty(othernodes) ? unique(dfagent.pos) : pthernodes
    
    Tₗ, Tᵤ = extrema(dfmodel.step)
    time =  Tₗ:Tᵤ
    X = hcat(dfmodel.X...)'

    idx, τdx  = findall(ε -> !ismissing(ε) && ε == εₕ, dfagent.ε) |> extrema

    shocknode = dfagent[idx, :pos]
    shocktime = dfagent[τdx, :step]

    lowerbound = minimum(X[1:(shocktime - Tₗ), :])

    ∑X = positive.(sum(X, dims=2))

    figure = plot(
        ylims=(lowerbound, Inf),
        gridalpha=1, grid=:y,
        xlabel=latexstring("\$ t \$")
    )
    
    plot!(figure,
        time, X[:, shocknode], c=cᵪ, 
        label=latexstring("\$ X_{$shocknode, t} \$"))
    
    for (i, node) in enumerate(filter(n -> n != shocknode, othernodes))
        label = i == 1 ? latexstring("\$ X_{$node, t} \$") : false
        plot!(figure, time, X[:, node], c=cₚ, label=label)
    end
    
    bar!(
        figure, 
        time, ∑X, 
        c=cₐ,
        linewidth=0, linecolor=cₐ, 
        label=latexstring("\$ \\sum_i X_{i, t} \$"), 
        legend=:topleft)
    
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
    
coherencecolors = [makecolor(:cobalto)(), makecolor(:orange)()]

function compareblackout(excdemand, ns; savepath=nothing)
	blackoutlabel = latexstring("\$\\{t: t \\geq \\tau, \\sum_{i} X_{i, t} > 0 \\} \$")
    coherencelabel = latexstring("\$ n \$")
    
    figure = plot(xlabel=coherencelabel, ylabel=blackoutlabel, yticks=0:1:10, )
    
    for (i, results) in enumerate(excdemand)

        graphname, data = results
        
        col = coherencecolors[i]

        presentrows = any((!isnan).(data), dims=2) |> vec

        _, blk = eachcol(data[presentrows, :])

        cumulativeblackout = floor.(Int64, blk)

        bar!(
            figure, ns, cumulativeblackout;
            linewidth=0, linecolor=col,
            c=col, label=graphname)
    
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
        
        col = coherencecolors[i]
        
        ρs = data[:, 1]

        notnan = (!isnan).(ρs)
        
        scatter!(figure, ns[notnan], ρs[notnan]; markersize=4, c=col, label=graphname, legend=:topleft)

        plot!(figure, ns[notnan], ρs[notnan]; alpha=0.5, c=col, label=nothing)
    
    end
    
    
    if !isnothing(savepath)
        savefig(figure, savepath)
    end
    return figure
end


    function plotstabilityβ(prices, βs; node=1, savepath=nothing)
    
    pmin, pmax = extrema(prices[:, :, 1])
    bound = min(abs(pmin), abs(pmax))
    
    T = size(prices, 2)
    
    βfig = plot(title="Stability with respect to β")
    
    for (idx, β) in enumerate(βs)
        plot!(βfig, 1:T, prices[idx, :, node], 
        label=latexstring("\$ \\beta = $β \$"), 
        xlabel=latexstring("\$ t \$"),
        ylabel=latexstring("\$ p_t \$"), ylims=bound,
        c=Plots.palette(:tab10)[idx])
    end

    
    if !isnothing(savepath)
    savefig(βfig, savepath)
    end 
    
    return βfig

    end