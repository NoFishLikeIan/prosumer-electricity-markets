function plotg(g, environment)
    
    c_grid = range(-10., 10., length=100)
    p_grid = range(2., 10., length=4)
    colors = [:red, :orange, :green, :blue]
    endowments = environment.weather.state_values

    plot(
        xaxis="c", yaxis="demand", 
        title="Policy function", legend=:bottomright, dpi=200)

    for (p, e) in cartesian(p_grid, endowments)

        color = colors[findfirst(==(p), p_grid)]
        alpha = e == endowments[1] ? 0.5 : 1.

        Δc = @. c_grid - g(c_grid, p, e)
        demand = @. e + Δc / p
        plot!(c_grid, demand,
            label="p=$(round(p; digits=2)), e=$e", 
            c=color, alpha=alpha)
    end

    savefig("plots/markets/policy.png")

end