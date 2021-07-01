function makeline(n)
    ι = ones(Int64, n - 1)
    A = diagm(1 => ι, -1 => ι)

    ιₑ = ones(Int64, n - 2)
    G = diagm(1 => ιₑ, -1 => -ιₑ)

    return A, G
end

"""
- i, j edges; 
- there are n edges of form (1, j), n-1 of form (2, j) and so on;
- G is symmetric
"""
function makecomplete(n::Int64)
    A = ones(Int64, n, n)
    A[diagind(A)] .= 0

    E = map(edgetotuple, edges(SimpleGraph(A)))

    nₑ = length(E)
    G = zeros(Int64, nₑ, nₑ)

    for (row, e₁) in enumerate(E), (col, e₂) in enumerate(E)

        if row == col || isempty(e₁ ∩ e₂) continue end

        e = first(e₁ ∩ e₂)

        isoptionone = (e == first(e₁))
        iscorrect = (e == first(e₂))

        if isoptionone ⊻ iscorrect
            G[row, col] = -1
        else
            G[row, col] = 1
        end

    end

    return A, G
end

function makestar(n::Int64)
    A = zeros(Int64, n, n)

    A[1, 2:end] .= 1
    A += A'

    G = ones(Int64, n - 1, n - 1)
    G[diagind(G)] .= 0

    return A, G
end
