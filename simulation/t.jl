include("src/makegraph.jl")
include("src/utils.jl")

using LinearAlgebra, LightGraphs, Plots

function seqfrac(n::Int64)::Rational{Int64}
    if n == 1 return 1 // 1 end 
    if n == 2 return 3 // 4 end
    
    return seqfrac(n - 1) - seqfrac(n - 2) // 4
end


function minor(A, i, j)
    m, n = size(A)
    B = similar(A, m - 1, n - 1)
    for j′ in 1:j - 1, i′ in 1:i - 1; B[i′,j′] = A[i′,j′]; end
    for j′ in 1:j - 1, i′ in i + 1:m; B[i′ - 1,j′] = A[i′,j′]; end
    for j′ in j + 1:n, i′ in 1:i - 1; B[i′,j′ - 1] = A[i′,j′]; end
    for j′ in j + 1:n, i′ in i + 1:m; B[i′ - 1,j′ - 1] = A[i′,j′]; end
    return B
end

function heatmatrix(A)
    heatmap(reverse(A, dims=1))
end

T(n) = I + 0.5 * last(makepath(n + 1))

B(n) = 2I + last(makepath(n + 1))

C(n) = det(T(n)) * inv(T(n))
M(n, i, j) = minor(T(n), i, j)

diagonal(n, i) = 2 * (i - ( i^2 / (n + 1)))

n, i, j = 15, 4, 5

Mₒ = M(n, i, j)

M₁ = minor(Mₒ, 1, 1)
M₂ = minor(Mₒ, 1, 2)

M₂₁ = minor(M₂, 1, 1)
M₂₂ = minor(M₂, 1, 2)


plot(
    heatmatrix(M(n - 2, i - 2, j - 2)),
    heatmatrix(M₂₁),
    size=(1200, 600)
)


function Mdet(n, i, j) 

    central = det(T(j - i - 1))

    bottom = det(T(n - j))

    top = det(T(i - 1))

    sign = (-1)^(2(n + 1) - (i + j)) / 2(j - i)

    return  sign * top * central * bottom
end

function analyticalTinv(n, i, j)
    factor = (i - (j * i) / (n + 1))
    
    return 2 * factor

end


function final(n, i, j)
    if i ≤ j
        i - (j * i) / (n + 1)
    else
        final(n, j, i)
    end
end

invB = zeros(n, n)
for i in 1:n, j in 1:n
    invB[i, j] = final(n, i, j)
end

iota = ones(n)
L = LowerTriangular(iota * iota')

twoeyeg = L * (I - (iota * iota') / (n + 1)) * L'

result = all(invB .≈ twoeyeg)