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
function plotnodes(dfagent, fn; nodestoplot=Int64[])
    nodes = unique(dfagent[!, :pos])

    nodes = isempty(nodestoplot) ? nodes : nodes[nodestoplot]

    Tₗ, Tᵤ = extrema(dfagent[!, :step])
    time = Tₗ:Tᵤ

    nodedata = (getnodedata(dfagent, node) for node in nodes)
    figures = map(data -> fn(time, data), nodedata)

    allfigures = plot(figures..., layout=length(figures))

    return allfigures
end
    
function isconstant(arr)
	notequal = findfirst(x -> x != arr[1], arr)
	
	return isnothing(notequal) ? true : false
end

    function rescaleto(arr, from, to)
    if isconstant(arr) return ones(length(arr)) * to end
    
    l, u = extrema(arr)

    scaledtounity = [(x - l) / (u - l) for x in arr]
    
    Δ = to - from

    return @. scaledtounity * Δ + from
end

palette = Dict(
    :red      => [0.870588, 0.101961, 0.101961],
    :sand     => [0.94902, 0.827451, 0.596078],
    :magnolia => [0.909804, 0.921569, 0.968627],
    :orange   => [0.843137, 0.521569, 0.129412],
    :blue     => [0.615686274509804, 0.7294117647058823, 1.0]
)
    
function makecolor(colorsymbol)
    r, g, b = palette[colorsymbol]
    colorfn(α=1.) = RGBA(r, g, b, α)
end