function endgrid(
    gridsizes::Tuple{2,Int}, prosumer::Prosumer, environment::Environment;
    maxiter=1_000, tol=1e-3, verbose=false, gridbounds=[0., 10.]
)
    @unpack weather = environment
    @unpack u, u′, ψ₁, ψ₂ = prosumer
    invu′ = u′

    endowments = weather.state_values
    D_e = length(endowments)
    N_c, N_p = gridsizes

    c_grid = range(gridbounds..., length=N_c)
    p_grid = range(gridbounds..., length=N_p)

    policy = repeat(c_grid, 1, N_p, D_e)
    space = collect.(Iterators.product(c_grid, p_grid, endowments)) 

    spaceidx = cartesianfromsize(N_c, N_p, D_e)
    exogenousidx = cartesianfromsize(N_p, D_e)

    for iter in 1:maxiter
        g = positive ∘ fromMtoFn(policy, c_grid, p_grid, endowments)
        inverse = similar(policy)

        @threads for (i, j, k) in spaceidx
            # Endogenous grid method for each c′
            c′, p = c_grid[i], p_grid[j]
            ϵ = endowments[k]

            p′ = ψ₁ * p

            c = 0. # TODO: Use Euler to find "c"

            inverse[i, j, k] = c
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
        err_distance = maximum(abs.(d))
        verbose && print("Iteration $iter / $max_iter: $(@sprintf("%.4f", err_distance)) \r")

        if err_distance < tol 
            verbose && print("Found policy in $iter iterations (|x - x'| = $(@sprintf("%.4f", err_distance)))\n")
            return g
        end

        ρ = ρ0 - iter / max_iter # Dynamic dumping parameter
        policy += ρ * d # Update with dumping parameter

    end
    
    throw(ConvergenceException(max_iter))
end