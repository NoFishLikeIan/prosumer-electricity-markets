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
Plot the ramp up of agents and the price in all markets
"""
function priceplot(dfagent; savepath=nothing)

    allprices = filter(!ismissing, dfagent[!, :p])

    jointfigure = plotnodes(
        dfagent,
        (time, nodedata) -> begin
        dfpros, dfprov, dfprod = nodedata
        node = dfpros[1, :pos]
            
        εperiods = lowendowmentperiods(dfpros)
        pricet = dfprov[!, :p]

        fig = plot(
            time, pricet, 
            ylims=extrema(allprices),
            title="Node $node", label="p", color=:blue, legend=:topleft)
            
        vspan!(fig, εperiods, color=:red, alpha=0.3, label=nothing)
            
        return fig

    end)

    if !isnothing(savepath)
        savefig(jointfigure, savepath)
    end

    return jointfigure
end

function supplyplot(dfagent; savepath=nothing)

    jointfigure = plotnodes(
        dfagent, 
        (time, nodedata) -> begin
            dfpros, _, dfprod = nodedata
        
            node = dfpros[1, :pos]
            
            εperiods = lowendowmentperiods(dfpros)
            supply = combine(groupby(dfprod, [:step]), :s => sum)[!, :s_sum]

            fig = plot(
                time, supply, 
                label="s", color=:green, title="Node $node", legend=:topleft)

            
            vspan!(fig, εperiods, color=:red, alpha=0.3, label=nothing)
            
            return fig        
    end)
    
    if !isnothing(savepath)
        savefig(jointfigure, savepath)
    end

    return jointfigure
end

function correlationplot(dfagent; savepath=nothing)

    jointfigure = plotnodes(
        dfagent,
        (time, nodedata) -> begin
            dfpros, _, dfprod = nodedata
            node = dfpros[1, :pos]
            
            εperiods = lowendowmentperiods(dfpros)
            supply = combine(groupby(dfprod, [:step]), :s => sum)[!, :s_sum]

            fig = plot(time, supply, label="s", color=:green, title="Node $node")

            
            vspan!(fig, εperiods, color=:red, alpha=0.3, label=nothing)
            
        return fig   
        end)
    
    if !isnothing(savepath)
        savefig(jointfigure, savepath)
    end

    return jointfigure

end