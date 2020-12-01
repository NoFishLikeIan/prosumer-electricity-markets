using GraphPlot, Cairo, Compose
using ColorSchemes, Colors
using LightGraphs

function mapto01(x::Float64, a::Float64, b::Float64)::Float64
    (x - a) / (b - a)
end

function plotgraph(
    g, path::String, title::String;
    coherence::IncoherenceLevels=nothing)

    F0, h = isnothing(coherence) ? computeincoherence(g) : coherence

    colors = get(ColorSchemes.redblue, mapto01.(h, -1., 1.))
    edge_colors = get(ColorSchemes.dense, [e.weight for e in edges(g)])

    nodelabel = 1:nv(g)

    path = joinpath(path, "$title.png")

    
    draw(PNG(path, 20cm, 20cm), 
        gplot(
            g,
            nodefillc=colors, nodelabel=nodelabel,
            nodesize=3, nodelabelsize=2, linetype="curve",
            edgestrokec=edge_colors
        ))
end