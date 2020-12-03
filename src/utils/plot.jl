using GraphPlot, Cairo, Compose
using ColorSchemes, Colors
using LightGraphs

function mapto01(x::Float64, a::Float64, b::Float64)::Float64
    (x - a) / (b - a)
end

function plotgraph(
    graph, path::String, title::String;
    coherence=nothing)

    F0, h = isnothing(coherence) ? computeincoherence(graph) : coherence

    colors = get(ColorSchemes.ice, mapto01.(h, -1.5, 1.5))
    edge_colors = get(ColorSchemes.amp, [e.weight for e in edges(graph)])

    nodelabel = 1:nv(graph)

    path = joinpath(path, "$title.png")

    
    draw(PNG(path, 20cm, 20cm), 
        gplot(
            graph,
            nodefillc=colors, nodelabel=nodelabel,
            nodesize=3, nodelabelsize=2, linetype="curve",
            edgestrokec=edge_colors
        ))
end