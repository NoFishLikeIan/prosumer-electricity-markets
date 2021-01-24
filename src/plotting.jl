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

"""
Plot in comparison the two forecasting rules
"""
function plotrules(pess, opt, environment, prosumer; path="plots/markets/polcomp.png")
    
    @unpack ψ₁, ψ₂ = prosumer

    c_grid = range(-10., 10., length=100)
    ps = [2., 10.]
    endowments = environment.weather.state_values

    plots = []

    for (p, e) in cartesian(ps, endowments)

        state = e == endowments[1] ? "low" : "high"
        price = p == ps[1] ? "low" : "high"

        current = plot(
            title="$state endowments, $price prices",
             xaxis="c", yaxis="demand", legend=:bottomright)
        
        Δc = @. c_grid - pess(c_grid, p, e)
        demand = @. Δc / p
        plot!(current, c_grid, demand, label="ψ = $(min(ψ₁, ψ₂))")

        Δc = @. c_grid - opt(c_grid, p, e)
        demand = @. Δc / p
        plot!(current, c_grid, demand, label="ψ = $(max(ψ₁, ψ₂))")

        push!(plots, current)
    end

    plot(plots...; layour=(2, 2), dpi=400)
    savefig(path)
end