function plotsimplesolution(
    policy, environment;
    p̄=10., m=1., # FIXME: Exogenous m
    path="plots/markets/simplesolution.png")

    prices = range(.2, p̄, length=100)
    
    f = makesimple(policy)

    endowments = environment.weather.state_values

    hline(
        [0.], title="Solution for m=$m", 
        xaxis="p", linestyle=:dash, color=:red,
        linealpha=0.5, 
        dpi=200, label=false)

    for e in endowments
        label = "g′ / (g - m) - 2 | m = $m, e=$e"

        h(p) = f(m, p, e)

        plot!(prices, h.(prices), label=label)
    end 

    savefig(path)

end