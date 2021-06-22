function getnodedata(dfagent, node)
    currentnode = dfagent[!, :pos] .== node
    dfnode = dfagent[currentnode, :]

    return groupby(dfnode, :agent_type)
end

function lowendowmentperiods(dfpros)
    ε = collect(Float64, dfpros[!, :ε])
    cons = findconsecutive(findall(.==(maximum(ε)), ε))

    return [(l, u + 1) for (l, u) in cons]
end

function getsquare(n::Int64)

    biggersquare = ceil(Int64, √(n))

    return (biggersquare, biggersquare)
end

"""
Pass a function that takes the nodedata and time and returns a figure
"""
function plotnodes(dfagent, fn)
    nodes = unique(dfagent[!, :pos])
    T = maximum(dfagent[!, :step])
    time = 0:T

    nodedata = (getnodedata(dfagent, node) for node in nodes)
    figures = map(data -> fn(time, data), nodedata)

    allfigures = plot(figures..., layout=getsquare(length(nodes)))

    return allfigures
end

"""
Plot the supply and the price in all markets
"""
function pricesupplyplot(dfagent; savepath=nothing)

    allprices = filter(!ismissing, dfagent[!, :p])

    jointfigure = plotnodes(
        dfagent,
        (time, nodedata) -> begin
        dfpros, dfprov, dfprod = nodedata
        node = dfpros[1, :pos]
            
        εperiods = lowendowmentperiods(dfpros)
        pricet = dfprov[!, :p]

        supply = combine(
            groupby(dfprod, [:step]), :s => sum
        )[!, :s_sum]

        fig = plot(
            time, pricet, 
            ylims=extrema(allprices),
            title="Node $node", label="p", color=:blue, 
            ylabel="p", legend=:topleft)
            
        vspan!(fig, εperiods, color=:red, alpha=0.3, label=nothing)

        plot!(
            twinx(fig), time, supply, ylabel="s",
            label="s", color=:green, legend=:bottomright)
            
        return fig

    end)

    if !isnothing(savepath)
        savefig(jointfigure, savepath)
    end

    return jointfigure
end

"""
Plot the proportion of optimistic producers
"""
function plotproducerbeliefs(dfagent; savepath=nothing)

    jointfigure = plotnodes(
        dfagent,
        (time, nodedata) -> begin
        dfpros, dfprov, dfprod = nodedata
        node = dfpros[1, :pos]
            
        εperiods = lowendowmentperiods(dfpros)

        optψ = maximum(model.Ψ)

        optimistic = combine(
            groupby(dfprod, [:step]),
            :ψ => col -> count(col .== optψ) / length(col)
        )[!, :ψ_function]

        fig = plot(
            time, optimistic, 
            ylims=(0, 1),
            title="Node $node", label="% of optimistic", color=:blue, legend=:topleft)
            
        vspan!(fig, εperiods, color=:red, alpha=0.3, label=nothing)
            
        return fig

    end)

    if !isnothing(savepath)
        savefig(jointfigure, savepath)
    end

    return jointfigure

end

function plotproviderbeliefs(dfagent; savepath=nothing)
    jointfigure = plotnodes(
        dfagent,
        (time, nodedata) -> begin
        dfpros, dfprov, dfprod = nodedata
        node = dfpros[1, :pos]
            
        εperiods = lowendowmentperiods(dfpros)

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
    end

    return jointfigure
end