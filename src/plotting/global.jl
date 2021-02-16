function plotsimplesolution(
    pess::Function, opt::Function,
    environment::Environment;
    path="plots/markets/simplesolution.png",
    kwargs...
)

    directory, format = split(path, '.')

    pessdir = "$(directory)_pess.$(format)"
    plotsimplesolution(
        pess, environment;
        path=pessdir, kwargs...
    )

    optdir = "$(directory)_opt.$(format)"
    plotsimplesolution(
        opt, environment;
        path=optdir, kwargs...
    )

end

function plotsimplesolution(
    policy::Function, environment::Environment;
    p̄=10., m=1.,
    path="plots/markets/simplesolution.png")

    prices = range(.2, p̄, length=100)
    
    f = makesimple(policy)

    endowments = environment.weather.state_values

    hline(
        [0.], title="Firm's optimization: p + X / X′ ", 
        xaxis="p", linestyle=:dash, color=:red,
        linealpha=0.5, 
        dpi=200, label=false)

    for e in endowments
        label = "m = $m, e=$e"

        h(p) = f(m, p, e)

        plot!(prices, h.(prices), label=label, legend=:bottomleft)
    end 

    savefig(path)

end