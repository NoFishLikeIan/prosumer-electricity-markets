function plotg(g, environment, prosumer; p̄=20.)
    
    m_grid = range(0., 10., length=100)
    ps = p̄ .+ [-10., 10.]
    p_grid = range(ps..., length=4)
    colors = [:red, :orange, :green, :blue]
    e = environment.weather.state_values[2]

    plot(
        xaxis="m", yaxis="m′", 
        title="Policy function", legend=:bottomright, dpi=200)

    for p in p_grid


        plot!(m_grid, g.(m_grid, p, e),
            label="p=$(round(p; digits=2))")
    end

    savefig("plots/markets/policy.png")

end

"""
Plot in comparison the two forecasting rules
"""
function plotrules(pess, opt, environment, prosumer; p̄=20., path="plots/markets/polcomp.png")
    
    @unpack ψ₁, ψ₂ = prosumer

    m_grid = range(0., 10., length=100)
    ps = p̄ .+ [-10., 10.]
    endowments = environment.weather.state_values

    plots = []

    for (p, e) in cartesian(ps, endowments)

        state = e == endowments[1] ? "low" : "high"
    price = p == ps[1] ? "low" : "high"

        current = plot(
            title="$state endowments, $price prices",
             xaxis="m", yaxis="demand", legend=:bottomright)
        
        demandpess = @. (m_grid - pess(m_grid, p, e)) / p
        plot!(current, m_grid, demandpess, label="ψ = $(min(ψ₁, ψ₂))")

        demandopt = @.  (m_grid - opt(m_grid, p, e) ) / p
        plot!(current, m_grid, demandopt, label="ψ = $(max(ψ₁, ψ₂))")
    
    push!(plots, current)
    end

    plot(plots...; layour=(2, 2), dpi=200)
    savefig(path)
end

"""
Plot multivariate simulation
"""
function plotsimulation(xs, es; path="plots/markets/simul.png")

    X = sum(xs, dims=2) # Aggregate demand

    peak = maximum(abs.(X))
    ylimits = (-peak, peak) .* 1.1

    endowment = plot(
        title="Electricity demand over bad endowments", xaxis="t", yaxis="X(t)", ylims=ylimits, dpi=300)

    plot!(endowment, 1:length(X), X, label="X(t)", linecolor=:black)

    for tup in findconsecutive(findall(e -> e < .5, es))
        vspan!(endowment, tup, linecolor=:blue, alpha=0.1, fillcolor=:blue, legend=false)
    end

    savefig(path)

end

function plottypes(policy, es; path="plots/markets/types.png")
    η = mean(policy, dims=2) .- 1

    endowment = plot(
        ylims=(0., 1.),
        title="Fraction of optimists", xaxis="t", yaxis="η", dpi=300)

    plot!(endowment, 1:length(η), η, label="η(t)", linecolor=:black)

    for tup in findconsecutive(findall(e -> e < .5, es))
        vspan!(endowment, tup, linecolor=:blue, alpha=0.1, fillcolor=:blue, legend=false)
    end

    savefig(path)
end

function plotdemand(policy, environment; path="plots/markets/pricedemand.png")
    prices = range(.05, 2.5, length=100)

    e = environment.weather.state_values[2]
    ms = [0., 5., 10.]

    plot(title="Energy demand given different cash levels", xaxis="p", yaxis="demand", dpi=200)

    for m in ms
        demand = @. (m - policy(m, prices, e)) / prices
        plot!(prices, demand, label="m′(p | m = $m)")
    end

    savefig(path)

end

function plotpricesdemand(xs, es, p; path="plots/markets/kde.png")
    X = sum(xs, dims=2) # Aggregate demand

    sim = DataFrame(
        Demand=reshape(X, length(X)), 
        Price=p, 
        Endowment=es)

    @df sim marginalkde(
        :Demand, :Price,
        xlabel="Demand", ylabel="Price",fc=:plasma, dpi=300)
    
    savefig(path)
end