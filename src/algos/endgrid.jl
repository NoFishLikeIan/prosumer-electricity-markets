"""
Compute a policy using the endogenous grid method, 
assuming exogenous forecasting rule Ψ
"""
function endgrid(
    gridsizes::Tuple{Int,Int}, prosumer::Prosumer, environment::Environment;
    maxiter=1_000, tol=1e-3, verbose=false, gridbounds=[0., 10.], ρ0=1.
)
    @unpack weather = environment
    @unpack u, u′, ψ₁, ψ₂, β = prosumer
    invu′ = u′ # FIXME: Only works if u′ = invu′, latter should come from prosumer

    endowments = weather.state_values
    D_e = length(endowments)
    N_c, N_p = gridsizes

    c_grid = range(gridbounds..., length=N_c)
    p_grid = range(0.01, 1.0, length=N_p) # TODO: Bounds for p?

    policy = ones(N_c, N_p, D_e)
    space = collect.(Iterators.product(c_grid, p_grid, endowments)) 

    spaceidx = cartesianfromsize(N_c, N_p, D_e)
    exogenousidx = cartesianfromsize(N_p, D_e)

    for iter in 1:maxiter
        g = positive ∘ fromMtoFn(policy, c_grid, p_grid, endowments)
        inverse = similar(policy)

        x(c, p, e) = e + (c - g(c, p, e)) / p # Energy demand function

        @threads for (i, j, k) in spaceidx
    
            # Endogenous grid method for each c′
            c′, p = c_grid[i], p_grid[j]
            ϵ = endowments[k]

            p′ = ψ₁ * p # Forecast of price
            P = weather.p[k, :]

            x′ = x.(c′, p′, endowments) # Next period demand, state contingent 

            rhs = β * (P'u′.(x′))
            Δc = (invu′(rhs) - ϵ) * p # c - g(c, p, e)
            f(x) = x - g(x, p, ϵ) - Δc # Root function of Δc
            
            try
                c = find_zero(f, g(0., p, ϵ)) # Use previous c as guess
                # print("c = $c\n")
                inverse[i, j, k] = c

            catch e
                print("(i, j, k) = ($i, $j, $k)\n")
                throw(e)
            end

        end
        
        newpolicy = similar(policy)

        @threads for (j, k) in exogenousidx
            c = inverse[:, j, k]
            ixs = sortperm(c) # FIXME: Maybe not necessary

            forwardpolicy = fromVtoFn(c[ixs], c_grid[ixs])
            newpolicy[:, j, k] = forwardpolicy.(c_grid)
        end

        # Updating
        d = newpolicy - policy
        errdistance = maximum(abs.(d))
        verbose && print("Iteration $iter / $maxiter: $(@sprintf("%.4f", errdistance)) \r")

        if errdistance < tol 
            verbose && print("Found policy in $iter iterations (|x - x'| = $(@sprintf("%.4f", errdistance)))\n")
            return g
        end

        ρ = ρ0 - iter / maxiter # Dynamic dumping parameter
        policy += ρ * d # Update with dumping parameter

    end
    
    throw("Did not converge in $maxiter iterations")
end