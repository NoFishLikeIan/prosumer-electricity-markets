function makereward!(R, policy, states, prosumer)
    n_state, m_policy = size(R)

    for idx in 1:m_policy
        c′ = policy[idx] # Next policy

        @threads for jdx in 1:n_state
            c, e, p = states[jdx, :] # Current policy, endowment, and price
            x = e + (c - c′) / p
            if x > 0 R[jdx, idx] = prosumer.u(x) end
        end
    end

    return R
end

function maketransition!(Q, states_idx, endchain)
    n, m, n′ = size(Q)
    for idx′ in 1:n′
        for jdx in 1:m
            for idx in 1:n
                idx_endowment = states_idx[idx, 3]

                a′, p′, e′ = states_idx[idx′, :]


            end
        end
    end
end