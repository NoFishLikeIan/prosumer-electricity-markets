function plotmarket(
    G::ElectricityMarket; 
    path="plots/markets/grid.png")

    g = Graph(G.A)
    nodelabel = 1:nv(g)

    gplot(g, nodelabel=nodelabel)
    savefig(path)
end