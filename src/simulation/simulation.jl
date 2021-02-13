
function simulate(
    prosumer::Prosumer, environment::Environment, T::Int; 
    exog=false, sizes=(400, 20), p̄=20., 
    kwargs...)

    pess, opt = solvepolicy(sizes, prosumer, environment; tol=1e-2, kwargs...)

    return simulate(pess, opt, prosumer, environment, T; sizes=sizes, kwargs...)

end

function simulate(
    pess::Function, opt::Function,
    prosumer::Prosumer, environment::Environment, T::Int; 
    exog=false, sizes=(400, 20), p̄=20., 
    kwargs...)

    @unpack ψ₁, ψ₂ = prosumer

    # Markov process for endowments
    es = QuantEcon.simulate(environment.weather, T)

    if exog
        # Simulate with an exogenous price
        ρ = ψ₁
        σ = 1.

        ϵ = rand(Normal(0, σ), T)
        p = zeros(Float64, T)
        p[1] = rand(Normal(p̄, σ))
        for t in 2:T p[t] = p̄ * (1 - ρ) + ρ * p[t - 1] + ϵ[t] end

        ms, xs, policy = decisionpath((pess, opt), p, es, prosumer, environment; kwargs...)
    else
        # Simulate with an endogenous price
        ms, xs, policy, p = decisionpath((pess, opt), findprice, es, prosumer, environment; kwargs...)
    end


    return ms, xs, policy, es, p
end