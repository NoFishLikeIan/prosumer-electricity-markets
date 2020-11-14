using LinearAlgebra

function sortbyreal(x::Union{Complex,Real}, y::Union{Complex,Real})
    if real(y) == real(x)
        return imag(y) > imag(x)
    else 
        return real(y) > real(x)
    end
end

function sortedeigvals(A::AbstractMatrix)
    λ = eigvals(A)

    return sort(λ, lt=sortbyreal)
end

function scaledspectralradius(A::AbstractMatrix)
    λ = sortedeigvals(A'A)
    ρ = maximum(norm.(eigvals(A)))

    return ρ / λ[end]
end 