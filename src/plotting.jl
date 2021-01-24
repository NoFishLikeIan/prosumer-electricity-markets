function plotg(g, environment, prosumer)
    
    c_grid = range(0., 10., length=100)
    ps = 1 / (1 - prosumer.ψ₁) .+ [-10., 10.]
    p_grid = range(ps..., length=4)
    colors = [:red, :orange, :green, :blue]
    e = environment.weather.state_values[2]

    plot(
        xaxis="c", yaxis="c′", 
        title="Policy function", legend=:bottomright, dpi=200)

    for p in p_grid


        plot!(c_grid, g.(c_grid, p, e),
            label="p=$(round(p; digits=2))")
    end

    savefig("plots/markets/policy.png")

end

"""
Plot in comparison the two forecasting rules
"""
function plotrules(pess, opt, environment, prosumer; path="plots/markets/polcomp.png")
    
    @unpack ψ₁, ψ₂ = prosumer

    c_grid = range(0., 10., length=100)
    ps = 1 / (1 - ψ₁) .+ [-10., 10.]
    endowments = environment.weather.state_values

    plots = []

    for (p, e) in cartesian(ps, endowments)

        state = e == endowments[1] ? "low" : "high"
        price = p == ps[1] ? "low" : "high"

        current = plot(
            title="$state endowments, $price prices",
             xaxis="c", yaxis="demand", legend=:bottomright)
        
        demandpess = @. (c_grid - pess(c_grid, p, e)) / p
        plot!(current, c_grid, demandpess, label="ψ = $(min(ψ₁, ψ₂))")

        demandopt = @.  (c_grid - opt(c_grid, p, e) ) / p
        plot!(current, c_grid, demandopt, label="ψ = $(max(ψ₁, ψ₂))")

        push!(plots, current)
    end

    plot(plots...; layour=(2, 2), dpi=400)
    savefig(path)
end