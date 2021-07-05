function getnodedata(dfagent, node)
    currentnode = dfagent[!, :pos] .== node
    dfnode = dfagent[currentnode, :]

    return groupby(dfnode, :agent_type)
end

function highdemandperiods(dfpros, model)

    highdemand = maximum(model.ε[2])
    cons = findconsecutive(findall(.==(highdemand), dfpros.ε))

    return [(l, u + 1) for (l, u) in cons]
end

function getlayout(n::Int64)

    biggersquare = ceil(Int64, √(n))

    return (biggersquare, biggersquare)
end

"""
Pass a function that takes the nodedata and time and returns a figure
"""
function plotnodes(dfagent, fn; maxnode=6)
    nodes = unique(dfagent[!, :pos])

    nodes = length(nodes) > maxnode ? nodes[1:maxnode] : nodes

    Tₗ, Tᵤ = extrema(dfagent[!, :step])
    time = Tₗ:Tᵤ

    nodedata = (getnodedata(dfagent, node) for node in nodes)
    figures = map(data -> fn(time, data), nodedata)

    allfigures = plot(figures..., layout=length(figures))

    return allfigures
end

"""
Plot the supply and the price in all markets
"""
function pricesupplyplot(dfagent, model; savepath=nothing)

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
            ylabel="p", legend=:topleft)
                    
        for (startp, endp) in εperiods
            vspan!(fig, [startp, endp], color=:red, alpha=0.3, label=nothing)
        end

        fig = bar!(
            twinx(fig), timeaxis, supply, ylabel="supply", alpha=0.2,
            label="s", color=:green, legend=:topright)
            
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

function plotpricevariance(dfagent, model; savepath=nothing)
    g = model.space.graph

    pricevariance = Float64[]

    nodelabel = unique(dfagent.pos)
    
    for node in nodelabel
        _, dfprov, _ = getnodedata(dfagent, node)
        σₚ = std(dfprov.p)

        push!(pricevariance, σₚ)
    end
        
    alphas = [var / maximum(pricevariance) for var in pricevariance]

    nodefillc = [RGBA(220 / 255, 20 / 255, 60 / 255, i) for i in alphas]

    if !isnothing(savepath)

        draw(
            PDF(savepath, 16cm, 16cm), 
            gplot(g, nodefillc=nodefillc, nodelabel=nodelabel, layout=circular_layout)
        )

    end


end

function rescaleto(arr, from, to)
    l, u = extrema(arr)

    scaledtounity = [(x - l) / (u - l) for x in arr]

    Δ = to - from

    return @. scaledtounity * Δ + from
end


function plotprofit(dfagent, model; savepath=nothing)
    g = model.space.graph

    nodelabel = unique(dfagent.pos)
    
    profit = sum(reshape(model.profit, length(nodelabel), :), dims=2)
        
    alphas = rescaleto(vec(profit), 0.5, 1.0)

    nodefillc = [RGBA(220 / 255, 20 / 255, 60 / 255, i) for i in alphas]

    if !isnothing(savepath)

        draw(
            PDF(savepath, 16cm, 16cm), 
            gplot(g, nodefillc=nodefillc, nodelabel=nodelabel, layout=circular_layout)
        )

    end


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