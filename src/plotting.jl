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

    plot(plots...; layour=(2, 2), dpi=200)
    savefig(path)
end

function plotsimulation(xs, policy, es; path="plots/markets/simul.png")

    endowment = plot(title="Electricity consumption over bad endowments and pessimism", xaxis="t", yaxis="x(t)", dpi=300)

    plot!(endowment, 1:length(xs), xs, label="x(t)", linecolor=:black)
    
    for tup in findconsecutive(findall(e -> e < .5, es))
        vspan!(endowment, tup, linecolor=:red, alpha=0.2, fillcolor=:red, legend=false)
    end

        
    for tup in findconsecutive(findall(e -> e == 1, policy))
        vspan!(endowment, tup, linecolor=:blue, alpha=0.5, fillcolor=:blue, legend=false)
    end

    savefig(path)

end

function plotdemand(policy, environment; path="plots/markets/pricedemand.png")
    prices = range(.05, 10., length=100)

    e = environment.weather.state_values[2]
    cs = [0., 5., 10.]

    plot(title="Demand over prices", xaxis="p", yaxis="demand", dpi=200)

    for c in cs
        demand = @. (c - policy(c, prices, e)) / prices
        plot!(prices, demand, label="c′(p | c = $c, e = $e)")
    end

    savefig(path)

end