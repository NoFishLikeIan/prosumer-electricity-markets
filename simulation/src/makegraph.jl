"""
Computes G matrix for arbitrary A
"""
function makeG(A)
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
	
	return G
end


function makeline(n)
    ι = ones(Int64, n - 1)
    A = diagm(1 => ι, -1 => ι)

    return A, makeG(A)
end

function makestar(n::Int64)
    A = zeros(Int64, n, n)

    A[1, 2:end] .= 1
    A += A'

    return A, makeG(A)
end
