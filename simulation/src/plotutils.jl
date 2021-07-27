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
    :blue       => [0, 49, 83, 255],
    :lightblue  => [130, 218, 224, 255],
    :red        => [255, 0, 0, 120],
    :siena      => [204, 102, 0, 255],
    :cobalto    => [88, 177, 196, 255],
    :canary     => [255, 255, 102, 255],
    :orange     => [255, 180, 0, 255]   
)
    
function makecolor(colorsymbol)
    r, g, b, α = palette[colorsymbol] ./ 255
    (α = α) -> RGBA(r, g, b, α)
end
