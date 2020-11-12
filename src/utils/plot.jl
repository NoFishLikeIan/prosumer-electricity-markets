using GraphPlot, Cairo, Compose, LightGraphs, Colors

function plotgraph(g, path::String, title)

    nodelabel = 1:nv(g)

    nodefillc = distinguishable_colors(nv(g), colorant"red")
    path = joinpath(path, "$title.png")

    
    draw(PNG(path, 16cm, 16cm), 
        gplot(g, nodefillc=nodefillc, nodelabel=nodelabel))
end